function order=getorder(imgseries)
N=numel(imgseries);
match_matrix=zeros(N,N);
desseries=cell(1,N);
locseries=cell(1,N);
% find all key points of each image
for a=1:1:N
    [~,desseries{a},locseries{a}]=sift(imgseries{a});
end
% count the numbers of best matches of every two images
for a=1:1:N
    for b=1:1:N
        if a~=b
            [~,inliers]=myRANSAC(desseries{a},locseries{a},desseries{b},locseries{b});
            match_matrix(a,b)=length(inliers);
        end
    end
end
% sort match_matrix column by column in descending way
match_sort=zeros(N,N);
for a=1:1:N
    [~,match_sort(:,a)]=sort(match_matrix(:,a),'descend');
end
% count the frequency of each index in the first two rows of match_sort
count=zeros(1,N);
for a=1:1:N
    count(a)=sum(match_sort(1:2,:)==a,'all');
end
% find ind as the start the image sequence
[~,ind]=min(count);
order=zeros(1,N);
order(1)=ind;
% get complete sequence from ind
for a=2:1:N
    k=1;
    while k<N && ismember(match_sort(k,ind),order)
        k=k+1;
    end
    order(a)=match_sort(k,ind);
    ind=order(a);
end
end

function [Hbest,best_inliers]=myRANSAC(des1,loc1,des2,loc2)
    %% matching
    kp1_loc=loc1;
    kp1_des=des1;
    kp2_loc=loc2;
    kp2_des=des2;
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