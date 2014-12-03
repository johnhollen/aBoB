function [straightenedImage] = fixPerspective(inImage, cornerPoints, centreWeight)
%This file will straighten up the image

%Fix the perspective in the image 
blackCount = zeros(3, 2);
search = true;

inBinary = binarize(inImage);
%tresh = graythresh(inImage);
%inBinary = im2bw(inImage, tresh);

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

factor = 7/6;

startPointJ = cornerPoints(1,2)-factor*blackCount(1,2);
startPointI = cornerPoints(1,1)-factor*blackCount(1,1);

movedCornerPoints(1,1) = cornerPoints(1,1)-factor*blackCount(1,1);
movedCornerPoints(1,2) = cornerPoints(1,2)-factor*blackCount(1,2);
movedCornerPoints(2,1) = cornerPoints(2,1)-factor*blackCount(2,1);
movedCornerPoints(2,2) = cornerPoints(2,2)+factor*blackCount(2,2);
movedCornerPoints(3,1) = cornerPoints(3,1)+factor*blackCount(3,1);
movedCornerPoints(3,2) = cornerPoints(3,2)-factor*blackCount(3,2);

row = floor(movedCornerPoints(1,1));
col = floor(movedCornerPoints(1,2));
while inBinary(row,col) == 0
    movedCornerPoints(1,1) = row;
    movedCornerPoints(1,2) = col;
    
    row = row-1;
    col = col-1;
end

row = floor(movedCornerPoints(2,1));
col = floor(movedCornerPoints(2,2));
while inBinary(row,col) == 0
    movedCornerPoints(2,1) = row;
    movedCornerPoints(2,2) = col;
    
    row = row-1;
    col = col+1;
end

row = floor(movedCornerPoints(3,1));
col = floor(movedCornerPoints(3,2));
while inBinary(row,col) == 0
    movedCornerPoints(3,1) = row;
    movedCornerPoints(3,2) = col;
    
    row = row+1;
    col = col-1;
end




tempCorner2 = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)+factor*blackCount(2,1)];
tempCorner3 = [cornerPoints(3,2)+factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)];

%Refine the new corners to get a better line
if inBinary(floor(tempCorner2(2)), floor(tempCorner2(1))) == 1
    i = floor(tempCorner2(2)); 
    j = floor(tempCorner2(1));
    while inBinary(i, j) == 1
        j = j-1;
        i = i-1;
        tempCorner2(1) = j;
        tempCorner2(2) = i;         
    end
end

if inBinary(floor(tempCorner3(2)), floor(tempCorner3(1))) == 1
    i = floor(tempCorner3(2)); 
    j = floor(tempCorner3(1));
    while inBinary(i, j) == 1
        i = i-1;
        j = j-1;
        tempCorner3(2) = i;
        tempCorner3(1) = j;
    end
end

%Calculate intersections
% Starting points in first row, ending points in second row
x = [movedCornerPoints(2,2) movedCornerPoints(3,2)-factor*blackCount(3,2);...
    tempCorner2(1) tempCorner3(1)];

y = [movedCornerPoints(2,1) movedCornerPoints(3,1);...
    tempCorner2(2) tempCorner3(2)];

dx = diff(x);  %# Take the differences down each column
dy = diff(y);
den = dx(1)*dy(2)-dy(1)*dx(2);  %# Precompute the denominator
ua = (dx(2)*(y(1)-y(3))-dy(2)*(x(1)-x(3)))/den;
ub = (dx(1)*(y(1)-y(3))-dy(1)*(x(1)-x(3)))/den;

xi = x(1)+ua*dx(1);
yi = y(1)+ua*dy(1);

O = [movedCornerPoints(2,2); movedCornerPoints(2,1)] - [movedCornerPoints(3,2); movedCornerPoints(3,1)];

d1 = tempCorner2' - [movedCornerPoints(2,2); movedCornerPoints(2,1)];
d1 = d1/norm(d1);
d2 = tempCorner3' - [movedCornerPoints(3,2); movedCornerPoints(3,1)];
d2 = d2/norm(d2);

D = [d2 -d1];
Dinv = inv(D);

t = D\O;

fourthCorner = [movedCornerPoints(2,2); movedCornerPoints(2,1)]+d1*t(2);
% plot(fourthCorner(1), fourthCorner(2), 'bo', 'linewidth', 3)
% plot(xi, yi, 'ro', 'linewidth', 3)
% plot(xi, fourthCorner(2), 'co', 'linewidth', 3);

fourthCorner = [xi, yi];

cellHeight = ((blackCount(1,1)+blackCount(2,1)+blackCount(3,1))/3)/3;
cellWidth = ((blackCount(1,2)+blackCount(2,2)+blackCount(3,2))/3)/3;

%Movingpoints all possible points imagineable.
movingPoints = [movedCornerPoints(1,2), movedCornerPoints(1,1);...
                movedCornerPoints(2,2), movedCornerPoints(2,1);...
                tempCorner2(1), tempCorner2(2);...
                movedCornerPoints(3,2), movedCornerPoints(3,1);...
                tempCorner3(1), tempCorner3(2)];
% 
moveFactorX = cellWidth*41;
moveFactorY = cellHeight*41;
% 
fixedPoints = [movedCornerPoints(1,2), movedCornerPoints(1,1);...
               movedCornerPoints(1,2)+moveFactorX, movedCornerPoints(1,1);...
               movedCornerPoints(1,2)+moveFactorX, movedCornerPoints(1,1)+7*cellHeight;...
               movedCornerPoints(1,2), movedCornerPoints(1,1)+moveFactorY;...
               movedCornerPoints(1,2)+7*cellWidth, movedCornerPoints(1,1)+moveFactorY];
           
width = norm([movedCornerPoints(1,2), movedCornerPoints(1,1)]-...
    [movedCornerPoints(1,2)+moveFactorX, movedCornerPoints(1,1)]);
height = norm([movedCornerPoints(1,2), movedCornerPoints(1,1)]-...
    [movedCornerPoints(1,2), movedCornerPoints(1,1)+moveFactorY]);

tform = fitgeotrans(movingPoints, fixedPoints, 'affine');
warpedImage = imwarp(inImage, tform, 'nearest', 'outputview', imref2d(size(inImage)), 'fillvalues', 1);

croppedImage = imcrop(warpedImage, [movedCornerPoints(1,2)-2, movedCornerPoints(1,1)-2, width+5, height+5]);

if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'nearest');
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'nearest');
end

corners = findCorners(croppedImage);
% figure, imshow(croppedImage)
% hold on
% plot(corners(1,1), corners(1,2), 'ro', 'linewidth', 2)
% plot(corners(2,1), corners(2,2), 'ro', 'linewidth', 2)
% plot(corners(3,1), corners(3,2), 'ro', 'linewidth', 2)
% plot(corners(4,1), corners(4,2), 'ro', 'linewidth', 2)
estimatedAllignment = (length(croppedImage)/41)*7;
fixedPoints = [1 1; 1 length(croppedImage); length(croppedImage) 1;...
    length(croppedImage)-estimatedAllignment+estimatedAllignment/14 length(croppedImage)-estimatedAllignment+estimatedAllignment/14];

% figure, imshow(croppedImage)
% hold on
% plot(fixedPoints(1,1), fixedPoints(1,2), 'rx')
% plot(fixedPoints(2,1), fixedPoints(2,2), 'rx')
% plot(fixedPoints(3,1), fixedPoints(3,2), 'rx')
% plot(fixedPoints(4,1), fixedPoints(4,2), 'rx')
% plot(corners(4,1), corners(4,2),'bx') 

tform = fitgeotrans(corners, fixedPoints, 'projective');

newWarpedImage = imwarp(croppedImage, tform, 'nearest', 'fillvalues', 1);

if size(newWarpedImage, 1) > size(newWarpedImage, 2)
   newWarpedImage = imresize(newWarpedImage, [size(newWarpedImage, 1) size(newWarpedImage, 1)], 'nearest');
elseif size(newWarpedImage, 1) < size(newWarpedImage, 2)
   newWarpedImage = imresize(newWarpedImage, [size(newWarpedImage, 2) size(newWarpedImage, 2)], 'nearest');
end

newCorners = findCorners(newWarpedImage);
newCroppedImage = imcrop(croppedImage, [corners(1,:), norm(corners(1,:)-corners(2,:)), norm(corners(1,:)-corners(3,:))]);
newCroppedTest = imcrop(newWarpedImage, [newCorners(1,:), norm(newCorners(1,:)-newCorners(2,:)), norm(newCorners(1,:)-newCorners(3,:))]);

%figure, imshow(newCroppedTest)

onlyQR = newCroppedTest;
thresh = graythresh(onlyQR);

onlyQR = im2bw(onlyQR, thresh);
%onlyQR = bwmorph(onlyQR, 'open');
%onlyQR = binarize(croppedImage);
 
%figure, imshow(onlyQR)

straightenedImage = onlyQR;