function [straightenedImage] = fixPerspective(inImage, cornerPoints)
%This file will straighten up the image

%Fix the perspective in the image 
blackCount = zeros(3, 2);
search = true;

%Use our own binarization method for binarization in this stage
inBinary = binarize(inImage);

%Count the black in the corners to estimate the width and height of the
%fiducialmarks

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

%Estimated cornerpoints of the QR-code
movedCornerPoints(1,1) = cornerPoints(1,1)-factor*blackCount(1,1);
movedCornerPoints(1,2) = cornerPoints(1,2)-factor*blackCount(1,2);
movedCornerPoints(2,1) = cornerPoints(2,1)-factor*blackCount(2,1);
movedCornerPoints(2,2) = cornerPoints(2,2)+factor*blackCount(2,2);
movedCornerPoints(3,1) = cornerPoints(3,1)+factor*blackCount(3,1);
movedCornerPoints(3,2) = cornerPoints(3,2)-factor*blackCount(3,2);

testCorners = zeros(3,2);
realCorner = zeros(3,2);

%Create a small area around the corner to finetune it
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
    
    %Find corners2: finds better corners than the estimated ones
    testCorners(i,:) = findCorners2(area, i);
    realCorner(i, 1) = fromRow+testCorners(i, 1);
    realCorner(i, 2) = fromCol+testCorners(i, 2);
    
end


%Find the fourth corner!
%Estimate cell height and width of the QR-code
cellHeight = ((blackCount(1,1)+blackCount(2,1)+blackCount(3,1))/3)/3;
cellWidth = ((blackCount(1,2)+blackCount(2,2)+blackCount(3,2))/3)/3;

%Estimated size of the QR-code
estHeight = cellHeight*41;
estWidth = cellWidth*41;

%Create a template for searching for the allignment pattern
template = ones(ceil(cellHeight*5), ceil(cellWidth*5));

template(1+1/5*size(template, 1):size(template, 1)-1/5*size(template, 1),...
    1+1/5*size(template, 2):size(template, 2)-1/5*size(template, 2)) = 0;

template(1+2/5*size(template, 1):size(template, 1)-2/5*size(template, 1),...
    1+2/5*size(template, 2):size(template, 2)-2/5*size(template, 2)) = 1;

%Dont search the whole QR-code, just the lower right corner
searchWidth = norm([realCorner(1,2), realCorner(1,1)]-[realCorner(2,2), realCorner(2,1)]);
searchHeight = norm([realCorner(1,2), realCorner(1,1)]-[realCorner(3,2), realCorner(3,1)]);

searchIm = imcrop(inImage, [realCorner(1,2)+searchWidth/2 realCorner(1,1)+searchHeight/2 searchWidth/2, searchHeight/2]);

c = normxcorr2(template, searchIm);

[ypeak, xpeak]   = find(c==max(c(:)));
% account for padding that normxcorr2 adds
yoffSet = ypeak-size(template,1);
xoffSet = xpeak-size(template,2);


allignmentCenter = [xoffSet+(xpeak-xoffSet)/2, yoffSet+(ypeak-yoffSet)/2];

%Transform allignmentcenter to image coordinates
realAllign(1,1) = realCorner(1,1)+searchHeight/2+allignmentCenter(1,2);
realAllign(1,2) = realCorner(1,2)+searchWidth/2+allignmentCenter(1,1);

%Fix the perspective 

%Estimate where the real allignment pattern should be 
estAllignment = [realCorner(1,1)+estHeight-(7)*cellHeight+cellHeight/3,...
    realCorner(1,2)+estWidth-(7)*cellWidth+cellWidth/3];

fixedPoints = [realCorner(1,2) realCorner(1,1); realCorner(1,2)+estWidth realCorner(1,1);...
    realCorner(1,2) realCorner(1,1)+estHeight; estAllignment(1,2) estAllignment(1,1)];

movingPoints = [realCorner(1,2) realCorner(1,1); realCorner(2,2) realCorner(2,1);...
    realCorner(3,2) realCorner(3,1); realAllign(1,2) realAllign(1,1)]; 

%Do the transformation
tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
warpedImage = imwarp(inImage, tform, 'linear', 'outputview', imref2d(size(inImage)), 'fillvalues', 1);

cropWidth = norm([realCorner(1,2) realCorner(1,1)]-[realCorner(1,2)+estWidth realCorner(1,1)]);
cropHeight = norm([realCorner(1,2) realCorner(1,1)]-[realCorner(1,2) realCorner(1,1)+estHeight]);

%Crop the resulting Qr-code
croppedImage = imcrop(warpedImage, [realCorner(1,2) realCorner(1,1) cropWidth cropHeight]);

%Resize to make it square
if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'nearest');
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'nearest');
end

%Do the final binarization
thresh = graythresh(croppedImage);
onlyQR = im2bw(croppedImage, thresh);

%Return the QR-code 
straightenedImage = onlyQR;