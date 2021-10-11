%% read image
imgpath='.\sources\im02.jpg';

[image,keypoints_des,keypoints_loc]=sift(imgpath);
showkeys(imread(imgpath),keypoints_loc,keypoints_des);
