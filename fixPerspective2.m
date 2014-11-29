function [straightenedImage] = fixPerspective2(inImage, cornerPoints,centreWeight)
%This file will straighten up the image


cornerPoints(1,:) = [cornerPoints(1,2)-centreWeight,cornerPoints(1,1)-centreWeight];
cornerPoints(2,:) = [cornerPoints(2,2)+centreWeight,cornerPoints(2,1)-centreWeight];

width = norm(cornerPoints(2,:)-cornerPoints(1,:));
height = norm(cornerPoints(3,:)-cornerPoints(1,:));
 
diffX= floor(width/10);
diffY= floor(height/10);
 
width=width+2*diffX;
height=height+2*diffY;
 
startPointI = cornerPoints(1,1)-diffX; 
startPointJ = cornerPoints(1,2)-diffY;


croppedImage = imcrop(inImage, [startPointI, startPointJ, width, height]);

%Now, fix the perspective

if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'bicubic'); diff = diffX;
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'bicubic'); diff = diffY;
else
    diff=diffX;
end

[corners,AP] = findCorners2(croppedImage,diff);
newCorners = corners;

movingpoints=[corners(1,:) ; corners(2,:) ; corners(3,:) ; corners(4,:)];
fixedpoints=[1 1;1 length(croppedImage);length(croppedImage) 1;length(croppedImage) length(croppedImage)];

tform = fitgeotrans(movingpoints,fixedpoints,'projective');
newcroppedImage = imwarp(croppedImage,tform, 'bicubic', 'fillvalues', 1);

if size(newcroppedImage, 1) > size(newcroppedImage, 2)
   newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 1) size(newcroppedImage, 1)], 'bicubic');
elseif size(newcroppedImage, 1) < size(newcroppedImage, 2)
   newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 2) size(newcroppedImage, 2)], 'bicubic');
end

figure
imshow(newcroppedImage);
%Crop the white from the transformed image and find the alignment pattern!
%[newCorners,alignmentCenter] = findCorners(newcroppedImage,diff);

%onlyQR = imcrop(newcroppedImage,...
%    [newCorners(1,1), newCorners(1,2), norm(newCorners(1,:)-newCorners(3,:)), norm(newCorners(1,:)-newCorners(2,:))]);

%thresh = graythresh(onlyQR);

%onlyQR = im2bw(onlyQR, thresh);
%onlyQR = bwmorph(onlyQR, 'erode');

%figure, imshow(onlyQR)

straightenedImage = zeros(13,13);%onlyQR;