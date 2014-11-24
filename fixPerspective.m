function [straightenedImage] = fixPerspective(inImage, cornerPoints,centreWeight)
%This file will straighten up the image

figure
imshow(inImage);
hold on 
 plot(cornerPoints(1,2)-centreWeight,cornerPoints(1,1)-centreWeight,'bo','linewidth',3);
 plot(cornerPoints(2,2)+centreWeight,cornerPoints(2,1)-centreWeight,'bo','linewidth',3);
 plot(cornerPoints(3,2)-centreWeight,cornerPoints(3,1)+centreWeight,'bo','linewidth',3);

cornerPoints(1,:) = [cornerPoints(1,2)-centreWeight,cornerPoints(1,1)-centreWeight];
cornerPoints(2,:) = [cornerPoints(2,2)+centreWeight,cornerPoints(2,1)-centreWeight];
cornerPoints(3,:) = [cornerPoints(3,2)-centreWeight,cornerPoints(3,1)+centreWeight];

%%%% DO THIS !! CHECK 10 % surrounding area of cornerpoint after a more accurate corner point
%%%% with Harris corner detection

dimz = floor(length(inImage)/100);  % 10 % of size 
diffZ = floor(dimz/2); % To find old centrePoint


newCorners1 = zeros(3,2);
% The three new corners
for j=1:3
    newmatrix = inImage(cornerPoints(j,2)-dimz:cornerPoints(j,2)+dimz, ...
    cornerPoints(j,1)-dimz:cornerPoints(j,1)+dimz);

    figure
    imshow(newmatrix);

    newCorners1(j,:) = corner(newmatrix,'Harris',1);
end



newCorners1 = cornerPoints +(newCorners1-dimz)/dimz;

% plot(newCorners1(1,2),newCorners1(1,1),'ro','linewidth',3);
% plot(newCorners1(2,2),newCorners1(2,1),'ro','linewidth',3);
% plot(newCorners1(3,2),newCorners1(3,1),'ro','linewidth',3);

%Fix the perspective in the image 
blackCount = zeros(3, 2);
search = true;

inBinary = binarize(inImage);

%Count the black in the corners

% %Rows
% for i = 1:length(cornerPoints)
%    row = floor(cornerPoints(i, 1));
%    col = floor(cornerPoints(i, 2));
%    blackCounterRow = 0;
%      
%    %Loop in positive direction
%    while search
%        if inBinary(row, col) == inBinary(row+1, col);
%           blackCounterRow = blackCounterRow+1;
%           row = row+1;
%        else
%           search = false;
%        end
%    end
% 
%    search = true;
%    row = floor(cornerPoints(i, 1));
%    %Loop in negative direction
%    while search
%        if inBinary(row, col) == inBinary(row-1, col)
%           blackCounterRow = blackCounterRow+1;
%           row = row-1;
%           
%        else
%            search = false;
%        end
%    end
%    blackCount(i, 1) = blackCounterRow;
%  
%    search = true;
% end
% 
% %Columns
% for i = 1:length(cornerPoints)
%    row = floor(cornerPoints(i, 1));
%    col = floor(cornerPoints(i, 2));
%    blackCounterCol = 0;
%    
%    %Loop in positive direction
%    while search
%        if inBinary(row, col) == inBinary(row, col+1);
%           blackCounterCol = blackCounterCol+1;
%           col = col+1;
%        else
%           search = false;
%        end
%    end
%    
%    search = true;
%    col = floor(cornerPoints(i, 2));
%    %Loop in negative direction
%    while search
%        if inBinary(row, col) == inBinary(row, col-1)
%           blackCounterCol = blackCounterCol+1;
%           col = col-1;
%           
%        else
%            search = false;
%        end
%    end
% 
%    blackCount(i, 2) = blackCounterCol;
%  
%    search = true;
% end

factor = 1.8;

startPointJ = cornerPoints(1,2)-factor*blackCount(1,2);
startPointI = cornerPoints(1,1)-factor*blackCount(1,1);

width = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)-factor*blackCount(2,1)]-[startPointJ, startPointI];
width = norm(width);
height = [cornerPoints(3,2)-factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)]-[startPointJ, startPointI];
height = norm(height);

croppedImage = imcrop(inImage, [startPointJ, startPointI, width, height]);

%Now, fix the perspective

if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'bicubic');
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'bicubic');
end

[corners,AP] = findCorners(croppedImage);
newCorners = corners;

movingpoints=[corners(1,:) ; corners(2,:) ; corners(3,:) ; corners(4,:)];
fixedpoints=[1 1;1 length(croppedImage);length(croppedImage) 1;length(croppedImage) length(croppedImage)];

% figure
% imshow(croppedImage);
% hold on 
% plot(AP(2),AP(1),'bo','linewidth',3);
% 
% plot(corners(1,2),corners(1,1),'ro','linewidth',3);
% plot(corners(2,2),corners(2,1),'ro','linewidth',3);
% plot(corners(3,2),corners(3,1),'ro','linewidth',3);
% plot(corners(4,2),corners(4,1),'ro','linewidth',3);

%corners

tform = fitgeotrans(movingpoints,fixedpoints,'projective');
newcroppedImage = imwarp(croppedImage,tform, 'bicubic', 'fillvalues', 1);

if size(newcroppedImage, 1) > size(newcroppedImage, 2)
   newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 1) size(newcroppedImage, 1)], 'bicubic');
elseif size(newcroppedImage, 1) < size(newcroppedImage, 2)
   newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 2) size(newcroppedImage, 2)], 'bicubic');
end

%Crop the white from the transformed image and find the alignment pattern!
%[newCorners,alignmentCenter] = findCorners(newcroppedImage);

onlyQR = imcrop(newcroppedImage,...
    [newCorners(1,1), newCorners(1,2), norm(newCorners(1,:)-newCorners(3,:)), norm(newCorners(1,:)-newCorners(2,:))]);

%plot(alignmentCenter(2),alignmentCenter(1),'ro','linewidth',3);


%onlyQR = binarize(onlyQR);

thresh = graythresh(onlyQR);

onlyQR = im2bw(onlyQR, thresh);
%onlyQR = bwmorph(onlyQR, 'erode');

straightenedImage = onlyQR;