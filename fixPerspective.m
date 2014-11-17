function [straightenedImage] = fixPerspective(inBinary, cornerPoints)
%This file will straighten up the image

%Fix the perspective in the image 
blackCount = zeros(3, 3);
search = true;

%Count the black in the corners

%Rows
for i = 1:length(cornerPoints)
   row = floor(cornerPoints(i, 1));
   col = floor(cornerPoints(i, 2));
   blackCounterRow = 0;
   
   %Loop in positive direction
   while search
       if inBinary(row, col) == inBinary(row+1, col);
          blackCounterRow = blackCounterRow+1;
          row = row+1;
       else
          search = false;
       end
   end

   search = true;
   row = floor(cornerPoints(i, 1));
   %Loop in negative direction
   while search
       if inBinary(row, col) == inBinary(row-1, col)
          blackCounterRow = blackCounterRow+1;
          row = row-1;
          
       else
           search = false;
       end
   end
   blackCount(i, 1) = blackCounterRow;
 
   search = true;
end

%Columns
for i = 1:length(cornerPoints)
   row = floor(cornerPoints(i, 1));
   col = floor(cornerPoints(i, 2));
   blackCounterCol = 0;
   
   %Loop in positive direction
   while search
       if inBinary(row, col) == inBinary(row, col+1);
          blackCounterCol = blackCounterCol+1;
          col = col+1;
       else
          search = false;
       end
   end
   
   search = true;
   col = floor(cornerPoints(i, 2));
   %Loop in negative direction
   while search
       if inBinary(row, col) == inBinary(row, col-1)
          blackCounterCol = blackCounterCol+1;
          col = col-1;
          
       else
           search = false;
       end
   end

   blackCount(i, 2) = blackCounterCol;
 
   search = true;
end
factor = 9.0/6.0;

startPointJ = cornerPoints(1,2)-factor*blackCount(1,2);
startPointI = cornerPoints(1,1)-factor*blackCount(1,1);

width = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)-factor*blackCount(2,1)]-[startPointJ, startPointI];
width = norm(width);
height = [cornerPoints(3,2)-factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)]-[startPointJ, startPointI];
height = norm(height);
edgePoint = [startPointJ+width, startPointI+height];

croppedImage = imcrop(inBinary, [startPointJ, startPointI, width, height]);

%Now, fix the perspective

if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'nearest');
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'nearest');
end

figure
imshow(croppedImage)

hold on 

corners = findCorners(croppedImage);

plot(corners(1,1),corners(1,2), 'ro', 'linewidth', 3);
plot(corners(2,1),corners(2,2), 'go', 'linewidth', 3);
plot(corners(3,1),corners(3,2), 'mo', 'linewidth', 3);
plot(corners(4,1),corners(4,2), 'co', 'linewidth', 3);

movingpoints=[corners(1,:) ; corners(2,:) ; corners(3,:) ; corners(4,:)];
fixedpoints=[1 1;1 length(croppedImage);length(croppedImage) 1;length(croppedImage) length(croppedImage)];

tform = fitgeotrans(movingpoints,fixedpoints,'projective');
newcroppedImage = imwarp(croppedImage,tform, 'nearest', 'fillvalues', 1);

if size(newcroppedImage, 1) > size(newcroppedImage, 2)
   newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 1) size(newcroppedImage, 1)], 'nearest');
elseif size(newcroppedImage, 1) < size(newcroppedImage, 2)
   newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 2) size(newcroppedImage, 2)], 'nearest');
end

%Crop the white from the transformed image
newCorners = findCorners(newcroppedImage);

onlyQR = imcrop(newcroppedImage,...
    [newCorners(1,1), newCorners(1,2), norm(newCorners(1,:)-newCorners(3,:)), norm(newCorners(1,:)-newCorners(2,:))]);

onlyQR = bwmorph(onlyQR, 'open');

% figure
% imshow(onlyQR)

straightenedImage = onlyQR;


