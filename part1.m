%% read image
imgpath='.\im01.jpg';
input=double(rgb2gray(imread(imgpath)));

%% Sobel Kernel
versob_ker=[-1 0 1; -2 0 2; -1 0 1];
horsob_ker=[-1 -2 -1; 0 0 0; 1 2 1];

versob_output=myOwnConv2(versob_ker,input,'same');
horsob_output=myOwnConv2(horsob_ker,input,'same');
figure();
imshow(uint8(versob_output));
figure();
imshow(uint8(horsob_output));

%% Gaussian Kernel
gau_ker3=[1 2 1;
    2 4 2;
    1 2 1]./16;
gau_ker5=[1 4 6 4 1;
    4 16 24 16 4;
    6 24 36 24 6;
    4 16 24 16 4;
    1 4 6 4 1]./256;
gau_ker7=[0 0 0 5 0 0 0;
    0 5 18 32 18 5 0;
    0 18 64 100 64 18 0;
    5 32 100 100 100 32 5;
    0 18 64 100 64 18 5;
    0 5 18 32 18 5 0;
    0 0 0 5 0 0 0]./1073;
gau3_output=myOwnConv2(gau_ker3,input);
gau5_output=myOwnConv2(gau_ker5,input);
gau7_output=myOwnConv2(gau_ker7,input);
imshow(uint8(gau7_output));
%% Haar-like Masks
%%%%%%%%% the scale of the masks the user want to set %%%%%%%%%%%%%%%%%
scale=1;
%%%%%%%%% ------------------------------------------- %%%%%%%%%%%%%%%%%
haar1v=[-1 1];
haar1h=[-1;1];
haar2v=[1 -1 1];
haar2h=[1;-1;1];
haar3=[-1 1;1 -1];
haar1v_output=myOwnConv2(kron(haar1v,ones(scale,scale)),input);
haar1h_output=myOwnConv2(kron(haar1h,ones(scale,scale)),input);
haar2v_output=myOwnConv2(kron(haar2v,ones(scale,scale)),input);
haar2h_output=myOwnConv2(kron(haar2h,ones(scale,scale)),input);
haar3_output=myOwnConv2(kron(haar3,ones(scale,scale)),input);
figure();
imshow(uint8(haar1v_output));
figure();
imshow(uint8(haar1h_output));
figure();
imshow(uint8(haar2v_output));
figure();
imshow(uint8(haar2h_output));
figure();
imshow(uint8(haar3_output));
%% functions
function output=myOwnConv2(kernel, input, method)
arguments
    kernel double
    input double
    method string = "valid"
end
[h,w]=size(input);
[hk,wk]=size(kernel);
kernel=rot90(kernel,2);
if method=="valid"
    output=zeros(h-hk+1,w-wk+1);
    for i=1:1:size(output,1)
        for j=1:1:size(output,2)
            output(i,j)=sum(kernel.*input(i:i+hk-1,j:j+wk-1),'all');
        end
    end
elseif method=="same"
    output=zeros(h,w);
    newinput=zeros(h+hk-1,w+wk-1);
    newinput(fix((hk-1)/2)+1:h+hk-1-ceil((hk-1)/2),fix((wk-1)/2)+1:w+wk-1-ceil((wk-1)/2))=input;
    for i=1:1:size(output,1)
        for j=1:1:size(output,2)
            output(i,j)=sum(kernel.*newinput(i:i+hk-1,j:j+wk-1),'all');
        end
    end
end
end