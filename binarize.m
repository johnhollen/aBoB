function [binary] = binarize(image)
%BINARIZE used adaptive binarization to create binary image

%Extract width and height from the image
width = size(image, 2);
height = size(image, 1);

%Create binary image with adaptive tresholding
%Extension of Wellner's method
binaryImage = ones(height, width);

%Calculate integral image, matlab built in method
integImage = integralImage(image);

%s is the block size
%t is a percentage
s = round(width/8, 0);
t = 15;
sdiv = floor(s/2);

%Treshold
%Vectorized version instead of looping

i = 1:1:height;
j = 1:1:width;

x1 = i - sdiv;
x1(x1 <= 1) = 2;

x2 = i + sdiv;
x2(x2 > height+1) = height + 1;

y1 = j - sdiv;
y1(y1 <= 1) = 2;

y2 = j + sdiv;
y2(y2 > width+1) = width + 1;

count = (x2 - x1)'*(y2 - y1);

thenum = integImage(x2, y2)-integImage(x2, y1-1)-integImage(x1-1, y2)+integImage(x1-1, y1-1);

binaryImage(image.*count <= thenum*(100-t)*0.01) = 0;

binary = binaryImage;

