function [straightenedImage] = fixPerspective(inBinary, cornerPoints)
%This file will straighten up the image
figure
imshow(inBinary)
hold on
%Fix the perspective in the image 
blackCount = [];
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
factor = 9.0/6.5;

plot([cornerPoints(1,2),cornerPoints(2, 2)], [cornerPoints(1,1),cornerPoints(2, 1)],'go', 'linewidth', 3)
plot([cornerPoints(3,2),cornerPoints(2, 2)], [cornerPoints(3,1),cornerPoints(2, 1)],'go', 'linewidth', 3)
plot([cornerPoints(1,2),cornerPoints(3, 2)], [cornerPoints(1,1),cornerPoints(3, 1)],'go', 'linewidth', 3)

startPointJ = cornerPoints(1,2)-factor*blackCount(1,2);
startPointI = cornerPoints(1,1)-factor*blackCount(1,1);

width = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)-factor*blackCount(2,1)]-[startPointJ, startPointI];
width = norm(width);
height = [cornerPoints(3,2)-factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)]-[startPointJ, startPointI];
height = norm(height);
edgePoint = [startPointJ+width, startPointI+height];


%Some testing plots
plot([startPointJ, cornerPoints(2,2)+factor*blackCount(2,2)]...
    , [startPointI, cornerPoints(2,1)-factor*blackCount(2,1)], 'r', 'linewidth', 3);

plot([startPointJ, cornerPoints(3,2)-factor*blackCount(3,2)]...
    , [startPointI, cornerPoints(3,1)+factor*blackCount(3,1)], 'r', 'linewidth', 3);

plot([edgePoint(1,1), cornerPoints(3,2)-factor*blackCount(3,2)], [edgePoint(1,2), cornerPoints(3,1)+factor*blackCount(3,1)], 'b-', 'linewidth', 3);

plot([edgePoint(1,1), cornerPoints(2,2)+factor*blackCount(2,2)], [edgePoint(1,2), cornerPoints(2,1)-factor*blackCount(2,1)], 'b-', 'linewidth', 3);

croppedImage = imcrop(inBinary, [startPointJ, startPointI, width, height]);


%Now, fix the perspective

if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)]);
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)]);
end

figure
imshow(croppedImage)

straightenedImage = zeros(200);

