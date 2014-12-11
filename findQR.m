function [qrImage] = findQR(image)
%Function for finding and extracting the QR-code
image = im2double(image);
%Check dimension and normalize image
imageDim = size(image, 3);

greyScale = im2double(image);

%Create greyscale image if the image is in color
if imageDim == 3
   greyScale = (greyScale(:,:,1)+greyScale(:,:,2)+greyScale(:,:,3))/3;
end

%Binarizing the image
binary = binarize(greyScale);


%Find the finder pattern
%Look for ratio 1:1:3:1:1
height = size(binary, 1);
width = size(binary, 2);

segmentsY = zeros(200000, 4);

segmentsX = zeros(200000, 4);

%Check Horizontally and Vertically
%Optimizing the segments check
segmentCounter = 0;

step = 4; %For optimizaton

for i = 1:step:height
   connectedComp = bwconncomp(binary(i, :));   
   %There must be atleast 4 objects found for there to be a fiducial mark
   if connectedComp.NumObjects > 4      
       for sx = 1:length(connectedComp.PixelIdxList)-1
           lengthOfSegment = size(connectedComp.PixelIdxList{sx}, 1);
           firstWhiteX = connectedComp.PixelIdxList{sx}(lengthOfSegment);
           secondWhiteX = connectedComp.PixelIdxList{sx+1}(1);
           blackBetweenLength = secondWhiteX-firstWhiteX;
           
           segmentCounter = segmentCounter+1;
           %Store the first white segment
           segmentsX(segmentCounter, 1) = lengthOfSegment;
           segmentsX(segmentCounter, 2) = i;
           segmentsX(segmentCounter, 3) = firstWhiteX;
           segmentsX(segmentCounter, 4) = 1;
           
           segmentCounter = segmentCounter+1;
           
           %Store the black segment in between
           segmentsX(segmentCounter, 1) = blackBetweenLength;
           segmentsX(segmentCounter, 2) = i;
           segmentsX(segmentCounter, 3) = secondWhiteX-1;
           segmentsX(segmentCounter, 4) = 0;
           
       end       
   end   
end

segmentCounter = 0;

for j = 1:step:width
   connectedComp = bwconncomp(binary(:, j));   
   %There must be atleast 4 objects found for there to be a fiducial mark
   if connectedComp.NumObjects > 4      
       for sy = 1:length(connectedComp.PixelIdxList)-1
           lengthOfSegment = size(connectedComp.PixelIdxList{sy}, 1);
           firstWhiteY = connectedComp.PixelIdxList{sy}(lengthOfSegment);
           secondWhiteY = connectedComp.PixelIdxList{sy+1}(1);
           blackBetweenLength = secondWhiteY-firstWhiteY;
           
           segmentCounter = segmentCounter+1;
           %Store the first white segment
           segmentsY(segmentCounter, 1) = lengthOfSegment;
           segmentsY(segmentCounter, 2) = secondWhiteY;
           segmentsY(segmentCounter, 3) = j;
           segmentsY(segmentCounter, 4) = 1;
           
           segmentCounter = segmentCounter+1;
           
           %Store the black segment in between
           segmentsY(segmentCounter, 1) = blackBetweenLength;
           segmentsY(segmentCounter, 2) = secondWhiteY-1;
           segmentsY(segmentCounter, 3) = j;
           segmentsY(segmentCounter, 4) = 0;
           
       end       
   end   
end

%Error margin percentage
percentage = 0.32;
%Check the dark areas Vertically

%Look up the fiducial marks
findpattern = zeros(height,width);
for i = 4:length(segmentsY)-3
    if segmentsY(i, 4) == 0        
        middleBlack = segmentsY(i, 1);
        upWhite = segmentsY(i-1, 1);
        downWhite = segmentsY(i+1, 1);
        upBlack = segmentsY(i-2, 1);
        downBlack = segmentsY(i+2, 1);
       
        %Check middle to adjacent
        if abs(middleBlack-3*upWhite) <= percentage*middleBlack && abs(middleBlack-3*downWhite) <= percentage*middleBlack
           %Check edges
           if abs(upWhite-upBlack) < percentage*upWhite && abs(downWhite-downBlack) < percentage*downWhite
      
              findpattern(segmentsY(i-2, 2):segmentsY(i+2, 2), segmentsY(i-2, 3):segmentsY(i+2, 3)) = 1;
           end
        end
    end
end

for i = 4:length(segmentsX)-2
   if segmentsX(i, 4) == 0        
        middleBlack = segmentsX(i, 1);
        leftWhite = segmentsX(i-1, 1);
        rightWhite = segmentsX(i+1, 1);
        leftBlack = segmentsX(i-2, 1);
        rightBlack = segmentsX(i+2, 1);
 
        %Check middle to adjacent
        if abs(middleBlack-3*leftWhite) <= percentage*middleBlack && abs(middleBlack-3*rightWhite) <= percentage*middleBlack
           if abs(leftWhite-leftBlack) < percentage*leftWhite && abs(rightWhite-rightBlack) < percentage*rightWhite
              findpattern(segmentsX(i-2, 2):segmentsX(i+2, 2), segmentsX(i-2, 3):segmentsX(i+2, 3)) = 1;
           end
        end
    end 
end

[Labels ,nrLabels] = bwlabel(findpattern, 4);

%Find centrepoints
nrPoints = [nrLabels, 3];
for i = 1:nrLabels
   [row, col] = find(Labels == i); 
   
   %Check if the cornerPoints form a square
   point1 = [min(col), min(row)];
   point2 = [min(col), max(row)];
   point3 = [max(col), min(row)];

   length1 = point1 - point3;
   length2 = point1 - point2;
   
   if (abs(norm(length1)-norm(length2))) < 0.1 
      meanX = mean(col);
      meanY = mean(row);
   else % Take the median instead
       meanX = median(col);
       meanY = median(row);
   end
   
   tempIndexI = floor(meanY);
   tempIndexJ = floor(meanX);
  
   upperCoord = [0,0];
   downerCoord = [0,0];
   lefterCoord = [0,0];
   righterCoord = [0,0];
   
   %Make sure we get the center of the fiducial mark
   while binary(tempIndexI, tempIndexJ) == 0 && tempIndexI > 1 %Count black pixels again
      tempIndexI = tempIndexI - 1;
      upperCoord(1) = tempIndexJ;
      upperCoord(2) = tempIndexI;
   end

   tempIndexI = floor(meanY); %Reset the value

   while binary(tempIndexI, tempIndexJ) == 0 && tempIndexI < size(image, 1) %Count black pixels again
      tempIndexI = tempIndexI + 1;
      downerCoord(1) = tempIndexJ;
      downerCoord(2) = tempIndexI;
   end

   tempIndexI = floor(meanY); %Reset the value

   while binary(tempIndexI, tempIndexJ) == 0 && tempIndexJ > 1 %Count black pixels again
      tempIndexJ = tempIndexJ - 1;
      lefterCoord(1) = tempIndexJ;
      lefterCoord(2) = tempIndexI;
   end

   tempIndexJ = floor(meanX); %Reset the value

   while binary(tempIndexI, tempIndexJ) == 0 && tempIndexJ < size(image, 2)%Count black pixels again
      tempIndexJ = tempIndexJ + 1;
      righterCoord(1) = tempIndexJ;
      righterCoord(2) = tempIndexI;
   end   
   
   meanX = lefterCoord(1) + norm(righterCoord-lefterCoord)/2;
   meanY = upperCoord(2) + norm(downerCoord-upperCoord)/2;

   nr = length(row)+length(col);
   nrPoints(i, 1) = nr;
   nrPoints(i, 2) = meanY;
   nrPoints(i, 3) = meanX;
end

[~, order1] = sort(nrPoints(:,1), 'descend');
sortedNrPoints = nrPoints(order1, :);
sortedNrPoints = sortedNrPoints(1:3, 1:3);


%Rotate the image to be in line with x-axis
xAxis = [1,0];
% find the two points with lowest Y-coord to create a vector
[~, order] = sort(sortedNrPoints(:,2), 'ascend');
sortedCentre = sortedNrPoints(order,:);
sortedCentre = sortedCentre(1:2,2:3);

% Check which of the two remaining points who have lowest x-coord in order
% to get right direction of vector
[~, order] = sort(sortedCentre(:,1), 'ascend');
sortedCentre = sortedCentre(order,1:2);

% Perform vector operation in order to calculate the angle 
vecX = [sortedCentre(2,2),sortedCentre(2,1)]-[sortedCentre(1,2),sortedCentre(1,1)]; % p2-p1
vecX = vecX/norm(vecX);
vectorAngle = acos(dot(vecX,xAxis));


%Adjustment of the rotation
if vecX(1) < 0
   vectorAngle = vectorAngle - pi; 
end

center = [size(image, 1)/2; size(image, 2)/2];

% Rotate image
greyRotated = imrotate(greyScale, radtodeg(vectorAngle), 'bilinear', 'crop');


%Crop the QR-code, first draw lines outside the code. Rotate the
%centrepoints aswell

rotationMatrix = [cos(vectorAngle), -sin(vectorAngle); sin(vectorAngle), cos(vectorAngle)];

rotatedCentrePoints = sortedNrPoints(1:3, 2:3);

%Do the old switcheroo
rotatedCentrePoints = sortrows(rotatedCentrePoints, 1);
if rotatedCentrePoints(2, 2) < rotatedCentrePoints(1, 2)
   temp = rotatedCentrePoints(1,:);
   rotatedCentrePoints(1,:) = rotatedCentrePoints(2, :);
   rotatedCentrePoints(2,:) = temp;
end

%Rotate the cornerpoints with the same amount as the image
for i = 1:3    
    result = [rotatedCentrePoints(i, 1); rotatedCentrePoints(i, 2)];
    result = rotationMatrix*(result-center)+center;
    rotatedCentrePoints(i, 1) = result(1,1);
    rotatedCentrePoints(i, 2) = result(2,1);
end

%Fix the perspective in separate file
croppedQr = fixPerspective(greyRotated, rotatedCentrePoints);
qrImage = croppedQr;
