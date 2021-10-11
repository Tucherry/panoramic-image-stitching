%% read images
h1=imread('.\sources\im02.jpg');
h2=imread('.\sources\im01.jpg');

%% choose points
image(h1);
h1_points=ginput(4);
image(h2);
h2_points=ginput(4);

%% compute homography matrix and stitching images
H=findHomography(h1_points,h2_points);
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
            % check whether it is in overlapping region or not
            if sum(fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:))~=0
                fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:)=0.5*fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:)+0.5*h1_warp(i,j,:);
            else
                fimg(round(h1wy_min-yt_min)+i,round(h1wx_min-xt_min)+j,:)=h1_warp(i,j,:);
            end
        end
    end
end

%% plot
imshow(uint8(fimg));

%% functions
function H=findHomography(hp1,hp2)
A=zeros(8,9);
for x=1:1:4
    A(2*x-1,:)=[hp1(x,1) hp1(x,2) 1 0 0 0 -hp2(x,1)*hp1(x,1) -hp2(x,1)*hp1(x,2) -hp2(x,1)];
    A(2*x,:)=[0 0 0 hp1(x,1) hp1(x,2) 1 -hp2(x,2)*hp1(x,1) -hp2(x,2)*hp1(x,2) -hp2(x,2)];
end
[~,~,V]=svd(A);
H=reshape(V(:,end)/V(end,end),3,3)';
end
