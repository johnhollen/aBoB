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

movedCornerPoints(1,1) = cornerPoints(1,1)-factor*blackCount(1,1);
movedCornerPoints(1,2) = cornerPoints(1,2)-factor*blackCount(1,2);
movedCornerPoints(2,1) = cornerPoints(2,1)-factor*blackCount(2,1);
movedCornerPoints(2,2) = cornerPoints(2,2)+factor*blackCount(2,2);
movedCornerPoints(3,1) = cornerPoints(3,1)+factor*blackCount(3,1);
movedCornerPoints(3,2) = cornerPoints(3,2)-factor*blackCount(3,2);

% figure, imshow(inBinary)
% hold on
% plot(movedCornerPoints(1,2), movedCornerPoints(1,1), 'ro')
% plot(movedCornerPoints(2,2), movedCornerPoints(2,1), 'bo')
% plot(movedCornerPoints(3,2), movedCornerPoints(3,1), 'go')

testCorners = zeros(3,2);
realCorners = zeros(3,2);

for i = 1:3
    checkArea = [blackCount(i,1)/3, blackCount(i,2)/3];
    
    if movedCornerPoints(i,1)-checkArea(1) < 1
        fromRow = 1;
    else
        fromRow = movedCornerPoints(i,1)-checkArea(1);
    end
    
    if movedCornerPoints+checkArea(1) > size(inImage, 1)
        toRow = size(inImage, 1);
    else
        toRow = movedCornerPoints(i,1)+checkArea(1);
    end
    
    if movedCornerPoints(i,2)-checkArea(2) < 1
       fromCol = 1;
    else
        fromCol = movedCornerPoints(i,2)-checkArea(2);
    end
    
    if movedCornerPoints(i,2)+checkArea(2) > size(inImage, 2)
        toCol = size(inImage, 2);
    else
        toCol = movedCornerPoints(i,2)+checkArea(2);
    end
    
    fromCol = floor(fromCol);
    toCol = floor(toCol);
    fromRow = ceil(fromRow);
    toRow = ceil(toRow);
    
    area = inBinary(fromRow:toRow, fromCol:toCol);
    
    testCorners(i,:) = findCorners2(area, i);
    realCorner(i, 1) = fromRow+testCorners(i, 1);
    realCorner(i, 2) = fromCol+testCorners(i, 2);
    
end
testCorners
% realCorner(1, 1) = movedCornerPoints(1,1)+testCorners(1,1);
% realCorner(1, 2) = movedCornerPoints(1,2)+testCorners(1,2);
% realCorner(2, 1) = movedCornerPoints(2,1)+testCorners(3,1);
% realCorner(2, 2) = movedCornerPoints(2,2)+testCorners(3,2);
% realCorner(3, 1) = movedCornerPoints(3,1)+testCorners(2,1);
% realCorner(3, 2) = movedCornerPoints(3,2)+testCorners(2,2);

figure, imshow(inBinary)
hold on

plot(realCorner(1, 2), realCorner(1,1), 'rx', 'linewidth', 3)
plot(realCorner(2, 2), realCorner(2,1), 'rx', 'linewidth', 3)
plot(realCorner(3, 2), realCorner(3,1), 'rx', 'linewidth', 3)
% 
% plot(movedCornerPoints(1,2), movedCornerPoints(1,1), 'co')
% plot(movedCornerPoints(2,2), movedCornerPoints(2,1), 'co')
% plot(movedCornerPoints(3,2), movedCornerPoints(3,1), 'co')

% if(corners(i,1)-checkArea < 1)
%     fromRow = 1;
% else
%     fromRow=corners(i,1)-checkArea;
% end
% 
% if(corners(i,1)+checkArea > dimz)
%     toRow = dimz;
% else
%     toRow = corners(i,1)+checkArea; 
% end
% if(corners(i,2)-checkArea < 1)
%     fromCol = 1;
% else
%     toCol = corners(i,2)-checkArea
% end
% if(corners(i,2)+checkArea > dimz)
%     toCol=dimz;
% else
%     toCol = corners(i,2)+checkArea; 
% end
% 

% image(fromRow:toRow,fromCol:toCol);

% row = floor(movedCornerPoints(1,1));
% col = floor(movedCornerPoints(1,2));
% while inBinary(row,col) == 0
%     movedCornerPoints(1,1) = row;
%     movedCornerPoints(1,2) = col;
%     
%     row = row-1;
%     col = col-1;
% end
% 
% row = floor(movedCornerPoints(2,1));
% col = floor(movedCornerPoints(2,2));
% while inBinary(row,col) == 0
%     movedCornerPoints(2,1) = row;
%     movedCornerPoints(2,2) = col;
%     
%     row = row-1;
%     col = col+1;
% end
% 
% row = floor(movedCornerPoints(3,1));
% col = floor(movedCornerPoints(3,2));
% while inBinary(row,col) == 0
%     movedCornerPoints(3,1) = row;
%     movedCornerPoints(3,2) = col;
%     
%     row = row+1;
%     col = col-1;
% end
% 
% tempCorner2 = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)+factor*blackCount(2,1)];
% tempCorner3 = [cornerPoints(3,2)+factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)];
% 
% %Refine the new corners to get a better line
% if inBinary(floor(tempCorner2(2)), floor(tempCorner2(1))) == 1
%     i = floor(tempCorner2(2)); 
%     j = floor(tempCorner2(1));
%     while inBinary(i, j) == 1
%         j = j-1;
%         i = i-1;
%         tempCorner2(1) = j;
%         tempCorner2(2) = i;         
%     end
% end
% 
% if inBinary(floor(tempCorner3(2)), floor(tempCorner3(1))) == 1
%     i = floor(tempCorner3(2)); 
%     j = floor(tempCorner3(1));
%     while inBinary(i, j) == 1
%         i = i-1;
%         j = j-1;
%         tempCorner3(2) = i;
%         tempCorner3(1) = j;
%     end
% end

% cellHeight = ((blackCount(1,1)+blackCount(2,1)+blackCount(3,1))/3)/3;
% cellWidth = ((blackCount(1,2)+blackCount(2,2)+blackCount(3,2))/3)/3;
% 
% %Movingpoints all possible points imagineable.
% movingPoints = [movedCornerPoints(1,2), movedCornerPoints(1,1);...
%                 movedCornerPoints(2,2), movedCornerPoints(2,1);...
%                 tempCorner2(1), tempCorner2(2);...
%                 movedCornerPoints(3,2), movedCornerPoints(3,1);...
%                 tempCorner3(1), tempCorner3(2)];
% % 
% moveFactorX = cellWidth*41;
% moveFactorY = cellHeight*41;
% % 
% fixedPoints = [movedCornerPoints(1,2), movedCornerPoints(1,1);...
%                movedCornerPoints(1,2)+moveFactorX, movedCornerPoints(1,1);...
%                movedCornerPoints(1,2)+moveFactorX, movedCornerPoints(1,1)+7*cellHeight;...
%                movedCornerPoints(1,2), movedCornerPoints(1,1)+moveFactorY;...
%                movedCornerPoints(1,2)+7*cellWidth, movedCornerPoints(1,1)+moveFactorY];
%            
% width = norm([movedCornerPoints(1,2), movedCornerPoints(1,1)]-...
%     [movedCornerPoints(1,2)+moveFactorX, movedCornerPoints(1,1)]);
% 
% height = norm([movedCornerPoints(1,2), movedCornerPoints(1,1)]-...
%     [movedCornerPoints(1,2), movedCornerPoints(1,1)+moveFactorY]);
% 
% tform = fitgeotrans(movingPoints, fixedPoints, 'affine');
% warpedImage = imwarp(inImage, tform, 'nearest', 'outputview', imref2d(size(inImage)), 'fillvalues', 1);
% 
% croppedImage = imcrop(warpedImage, [movedCornerPoints(1,2)-2, movedCornerPoints(1,1)-2, width+5, height+5]);
% 
% if size(croppedImage, 1) > size(croppedImage, 2)
%    croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'nearest');
% elseif size(croppedImage, 1) < size(croppedImage, 2)
%    croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'nearest');
% end
% 
% corners = findCorners(croppedImage);
% 
% estimatedAllignment = (length(croppedImage)/41)*7;
% fixedPoints = [1 1; 1 length(croppedImage); length(croppedImage) 1;...
%     length(croppedImage)-estimatedAllignment+estimatedAllignment/14 length(croppedImage)-estimatedAllignment+estimatedAllignment/14];
% 
% tform = fitgeotrans(corners, fixedPoints, 'projective');
% 
% newWarpedImage = imwarp(croppedImage, tform, 'cubic', 'fillvalues', 1);
% 
% if size(newWarpedImage, 1) > size(newWarpedImage, 2)
%    newWarpedImage = imresize(newWarpedImage, [size(newWarpedImage, 1) size(newWarpedImage, 1)], 'nearest');
% elseif size(newWarpedImage, 1) < size(newWarpedImage, 2)
%    newWarpedImage = imresize(newWarpedImage, [size(newWarpedImage, 2) size(newWarpedImage, 2)], 'nearest');
% end
% 
% 
% newCorners = findCorners(newWarpedImage);
% 
% newCroppedImage = imcrop(croppedImage, [corners(1,:), norm(corners(1,:)-corners(2,:)), norm(corners(1,:)-corners(3,:))]);
% newCroppedTest = imcrop(newWarpedImage, [newCorners(1,:), norm(newCorners(1,:)-newCorners(2,:)), norm(newCorners(1,:)-newCorners(3,:))]);
% 
% % figure, imshow(newCroppedImage)
% % figure, imshow(newCroppedTest)
% % figure, imshow(newWarpedImage)
% 
% onlyQR = newCroppedImage;
% thresh = graythresh(onlyQR);
% 
% onlyQR = im2bw(onlyQR, thresh);
% %onlyQR = bwmorph(onlyQR, 'open');
% %onlyQR = binarize(croppedImage);
%  
% %figure, imshow(onlyQR)



straightenedImage = zeros(200);
