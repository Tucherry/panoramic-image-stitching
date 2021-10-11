clc;
clear;
%% read images
h1path='.\im01.jpg';
h2path='.\im02.jpg';
h1=imread(h1path);
h2=imread(h2path);

%% matching
[~,kp1_des,kp1_loc]=sift(h1path);
[~,kp2_des,kp2_loc]=sift(h2path);
% calculate distance of each descriptor to match key pooints
index=zeros(size(kp1_loc,1),2);
for i=1:1:size(kp1_loc,1)
    dist=inf;
    for j=1:1:size(kp2_loc,1)
        newdist=norm(kp1_des(i,:)-kp2_des(j,:),2);
        if newdist < dist
            if ismember(j,index(:,1))
                loc=find(index(:,1)==j);
                if index(loc,2)>newdist
                    dist=newdist;
                    index(i,:)=[j dist];
                    index(loc,:)=[0 0];
                end
            else
                dist=newdist;
                index(i,:)=[j dist];
            end
        end
    end
end
% remove unmatched key points on each image
index=index(:,1);
mkp1=kp1_loc(find(index>0),:);
index(index==0)=[];
mkp2=kp2_loc(index,:);
remain=find((mkp1(:,3)-2>0).*(mkp2(:,3)-2>0));
% store matched key points into new matrix for convenience of coding
mkp1=mkp1(remain,1:2);
mkp1=fliplr(mkp1);
mkp2=mkp2(remain,1:2);
mkp2=fliplr(mkp2);
[n_match,~]=size(mkp1);

%% show matching lines
figure();
imshow([h1 h2]);
hold on;
for i=1:1:n_match
    x=[mkp1(i,1) mkp2(i,1)+640];
    y=[mkp1(i,2) mkp2(i,2)];
    plot(x,y);
end

%% RANSAC
T=2000;
epsilon=1;
best_inliers=[];
n=5;
for iter=1:1:T
    rand_choose = randi([1 n_match],1,n);
    src=zeros(n,2);
    prc=zeros(n,2);
    for i=1:1:n
        src(i,:) = mkp1(rand_choose(i),:);
        prc(i,:) = mkp2(rand_choose(i),:);
    end
    H = findHomography(src,prc);
    error=zeros(n_match,1);
    for j=1:1:n_match
        new_points = H*[mkp1(j,:) 1]';
        new_points = new_points./new_points(end);
        error(j)=norm([mkp2(j,:) 1]-new_points',2);
    end
    % record the longest list of inliers.
    inliers=find(error<epsilon);
    if length(inliers)>length(best_inliers)
        best_inliers=inliers;
    end
    fprintf('iteration %d\n',iter);
end
%% plot best matching
figure();
imshow([h1 h2]);
hold on;
for i=1:1:length(best_inliers)
    ind=best_inliers(i);
    x=[mkp1(ind,1) mkp2(ind,1)+640];
    y=[mkp1(ind,2) mkp2(ind,2)];
    plot(x,y);
end


%% compute homography matrix and stitching images
H = findHomography(mkp1(best_inliers,:),mkp2(best_inliers,:));
tform=projective2d(H.');
[h1_warp,h1w_index]=imwarp(h1,tform);
[h,w,d]=size(h2);
% initialize stitching canvas
xt_max=max([w,h1w_index.XWorldLimits]);
xt_min=min([0,h1w_index.XWorldLimits]);
yt_max=max([h,h1w_index.YWorldLimits]);
yt_min=min([0,h1w_index.YWorldLimits]);
fimg=zeros(round(yt_max-yt_min),round(xt_max-xt_min),d,'uint8');
% stitching each image
fimg(round(1-yt_min):round(h-yt_min),round(1-xt_min):round(w-xt_min),:)=h2;
h1wx_min=h1w_index.XWorldLimits(1);
h1wx_max=h1w_index.XWorldLimits(2);
h1wy_min=h1w_index.YWorldLimits(1);
h1wy_max=h1w_index.YWorldLimits(2);
for i=1:1:round(h1wy_max-h1wy_min)
    for j=1:1:round(h1wx_max-h1wx_min)
        if sum(h1_warp(i,j,:))~=0
            if sum(fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:))~=0
                fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:)=0.5*fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:)+0.5*h1_warp(i,j,:);
            else
                fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:)=h1_warp(i,j,:);
            end
        end
    end
end

%% plot
figure();
imshow(fimg)

%% functions

function H=findHomography(hp1,hp2)
np=size(hp1,1);
A=zeros(2*np,9);
for x=1:1:np
    A(2*x-1,:)=[hp1(x,1) hp1(x,2) 1 0 0 0 -hp2(x,1)*hp1(x,1) -hp2(x,1)*hp1(x,2) -hp2(x,1)];
    A(2*x,:)=[0 0 0 hp1(x,1) hp1(x,2) 1 -hp2(x,2)*hp1(x,1) -hp2(x,2)*hp1(x,2) -hp2(x,2)];
end
[~,~,V]=svd(A);
H=reshape(V(:,end)/V(end,end),3,3)';
end