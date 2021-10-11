%% read images
clc;
clear;
im1path='.\test1.jpg';
im2path='.\test2.jpg';
im3path='.\test3.jpg';
im4path='.\test4.jpg';
im5path='.\test5.jpg';
imgseries={im1path,im2path,im3path,im4path,im5path};

img=mystitching(imgseries);
imshow(img);
%% functions
function Hbest=myRANSAC(h1path,h2path)
    %% matching
    [~,kp1_des,kp1_loc]=sift(h1path);
    [~,kp2_des,kp2_loc]=sift(h2path);
    index=zeros(size(kp1_loc,1),2);
    % calculate distance of each descriptor to match key pooints
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
    end
    Hbest=findHomography(mkp1(best_inliers,:),mkp2(best_inliers,:));
    % functions in function
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
end

function fimg=mystitching(imgseries)
    n_img=length(imgseries);
    Hseries=cell(1,n_img);
    % the H matrix for image 1 is I (unit matrix)
    Hseries{1}=diag([1 1 1]);
    imgsize=zeros(n_img,2);
    imgsize(1,:)=size(imread(imgseries{1}),1:2);
    % multiply H matrix until the Hseries{1}=I
    for i=2:1:length(imgseries)
        imgsize(i,:)=size(imread(imgseries{i}),1:2);
        H=myRANSAC(imgseries{i},imgseries{i-1});
        Hseries{i}=H*Hseries{i-1};
    end
    % calculate the range of tansformed images
    x_range=zeros(n_img,2);
    y_range=zeros(n_img,2);
    for i=1:1:n_img
        t=[[1 1 1];[imgsize(i,2) 1 1];[1 imgsize(i,1) 1];[imgsize(i,2) imgsize(i,1) 1]]*Hseries{i}';
        x_range(i,1)=min(t(:,1)./t(:,3));
        x_range(i,2)=max(t(:,1)./t(:,3));
        y_range(i,1)=min(t(:,2)./t(:,3));
        y_range(i,2)=max(t(:,2)./t(:,3));
    end
    % find the middle image
    x_median=median(x_range,2);
    [~,ind]=sort(x_median);
    imgmid=ind(round(n_img/2));
    % divide the H matrix of the middle one to transform other images to
    % the moddle image
    Hmid=Hseries{imgmid};
    for i=1:1:n_img
        Hseries{i}=Hseries{i}/Hmid;
    end
    % calculate the range of transformed images again because H matrixes
    % change
    for i=1:1:n_img
        tform=projective2d(Hseries{i}.');
        [images{i},t]=imwarp(imread(imgseries{i}),tform);
        x_range(i,1)=t.XWorldLimits(1);
        x_range(i,2)=t.XWorldLimits(2);
        y_range(i,1)=t.YWorldLimits(1);
        y_range(i,2)=t.YWorldLimits(2);
    end
    % initialize the panoramic canvas
    x_min=min([0;x_range(:,1)]);
    x_max=max([imgsize(:,2);x_range(:,2)]);
    y_min=min([0;y_range(:,1)]);
    y_max=max([imgsize(:,1);y_range(:,2)]);
    fimg=zeros(round(y_max-y_min),round(x_max-x_min),3,'uint8');
    % stitching each image to the panoramic canvas
    for i=1:1:n_img
        fprintf('stitching %d\n',i);
        img_warp=images{i};
        [h,w,~]=size(img_warp);
        for x=1:1:h
            for y=1:1:w
                if sum(img_warp(x,y,:))~=0
                    fx=round(y_range(i,1)-y_min)+x;
                    fy=round(x_range(i,1)-x_min)+y;
                    if sum(fimg(fx,fy,:))~=0
                        fimg(fx,fy,:)=fimg(fx,fy,:)*0.5+img_warp(x,y,:)*0.5;
                    else
                        fimg(fx,fy,:)=img_warp(x,y,:);
                    end
                end
            end
        end
    end
end