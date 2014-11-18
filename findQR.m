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

%level = graythresh(greyScale);
binary = binarize(greyScale);


%Find the finder pattern
%Look for ratio 1:1:3:1:1
height = size(binary, 1);
width = size(binary, 2);

segmentsY = zeros(20000, 4);
segmentSizeY = 0;
segmentY = 0;

segmentsX = zeros(20000, 4);
segmentSizeX = 0;
segmentX = 0;



%Check Horizontally and Vertically
for j = 1:width-1
    for i = 1:height-1        
        %Vertically
        if binary(i, j) == binary(i+1, j)
           segmentSizeY = segmentSizeY+1;
        else
            segmentY = segmentY+1;
            segmentsY(segmentY, 1) = segmentSizeY;
            segmentsY(segmentY, 2) = i;
            segmentsY(segmentY, 3) = j;
            segmentsY(segmentY, 4) = binary(i, j);
            
            segmentSizeY = 0;
        end
    end 
end
for i = 1:height-1
    for j = 1:width-1
        %Horizontally
        if binary(i, j) == binary(i, j+1)
            segmentSizeX = segmentSizeX+1;
        else
            segmentX = segmentX+1;
            segmentsX(segmentX, 1) = segmentSizeX;
            segmentsX(segmentX, 2) = i;
            segmentsX(segmentX, 3) = j;
            segmentsX(segmentX, 4) = binary(i, j);

            segmentSizeX = 0;
        end 
    end
end

percentage = 0.3;
%Check the dark areas Vertically
counterY = 0;
findpattern = zeros(height,width);
for i = 4:length(segmentsY)-3
    if segmentsY(i, 4) == 0

        %fprintf('black: %d, white: %d, black: %d, white: %d, black: %d \n',segments(i-2, 1), segments(i-1, 1), segments(i, 1), segments(i+1, 1), segments(i+2, 1));
        
        middleBlack = segmentsY(i, 1);
        upWhite = segmentsY(i-1, 1);
        downWhite = segmentsY(i+1, 1);
        upBlack = segmentsY(i-2, 1);
        downBlack = segmentsY(i+2, 1);
       
        %Check middle to adjacent
        if abs(middleBlack-3*upWhite) <= percentage*middleBlack && abs(middleBlack-3*downWhite) <= percentage*middleBlack
           %Check edges
           if abs(upWhite-upBlack) < percentage*upWhite && abs(downWhite-downBlack) < percentage*downWhite
              counterY = counterY+1;
              findpattern(segmentsY(i-2, 2):segmentsY(i+2, 2), segmentsY(i-3, 3):segmentsY(i+2, 3)) = 1;
           end
        end
    end
end

counterX = 0;

for i = 4:length(segmentsX)-2
   if segmentsX(i, 4) == 0
        %fprintf('black: %d, white: %d, black: %d, white: %d, black: %d \n',segmentsX(i-2, 1), segmentsX(i-1, 1), segmentsX(i, 1), segmentsX(i+1, 1), segmentsX(i+2, 1));
        
        middleBlack = segmentsX(i, 1);
        leftWhite = segmentsX(i-1, 1);
        rightWhite = segmentsX(i+1, 1);
        leftBlack = segmentsX(i-2, 1);
        rightBlack = segmentsX(i+2, 1);
 
        %Check middle to adjacent
        if abs(middleBlack-3*leftWhite) <= percentage*middleBlack && abs(middleBlack-3*rightWhite) <= percentage*middleBlack
           if abs(leftWhite-leftBlack) < percentage*leftWhite && abs(rightWhite-rightBlack) < percentage*rightWhite
              counterX = counterX+1;
              findpattern(segmentsX(i-2, 2):segmentsX(i+2, 2), segmentsX(i-3, 3):segmentsX(i+2, 3)) = 1;
           end
        end
    end 
end

[Labels ,nrLabels] = bwlabel(findpattern, 4);

%Find centrepoints
nrPoints = [];
for i = 1:nrLabels
   [row, col] = find(Labels == i);
   
   %Check if the cornerPoints form a rectangle
   point1 = [min(row), min(col)];
   point2 = [min(row), max(col)];
   point3 = [max(row), min(col)];
   point4 = [max(row), max(col)];
   
   cx = (point1(1,2)+point2(1,2)+point3(1,2)+point4(1,2))/4;
   cy = (point1(1,1)+point2(1,1)+point3(1,1)+point4(1,1))/4;  
   
   dd1=sqrt(cx-point1(1,2))+sqrt(cy-point1(1,1));
   dd2=sqrt(cx-point2(1,2))+sqrt(cy-point2(1,1));
   dd3=sqrt(cx-point3(1,2))+sqrt(cy-point3(1,1));
   dd4=sqrt(cx-point4(1,2))+sqrt(cy-point4(1,1));
   
   treshold = 15;
   if abs(dd1-dd2) < treshold && abs(dd1-dd3) < treshold && abs(dd1-dd4) < treshold      
      meanX = ((min(col)+max(col))/2)-(abs(cx-((min(col)+max(col))/2)));
      meanY = ((min(row)+max(row))/2)-(abs(cy-((min(row)+max(row))/2)));
   else % Take the median instead
       meanX = median(col);
       meanY = median(row);
   end

   nr = length(row)+length(col);
   nrPoints(i, 1) = nr;
   nrPoints(i, 2) = meanY;
   nrPoints(i, 3) = meanX;
end

[~, order1] = sort(nrPoints(:,1), 'descend');
sortedNrPoints = nrPoints(order1, :);
sortedNrPoints = sortedNrPoints(1:3, 1:3);
    
% ROTATING THE IMAGE 
vec4 = [1,0];
% find the two points with lowest Y-coord to create a vector
[~, order] = sort(sortedNrPoints(:,3));
sortedCentre = sortedNrPoints(order,:);
sortedCentre = sortedCentre(1:2,2:3);


% Check which of the two remaining points who have highest x-coord in order
% to get right direction of vector
[~, order] = sort(sortedCentre(:,2), 'descend');
sortedCentre = sortedCentre(order,1:2);

vecX = [sortedCentre(2,1),sortedCentre(2,2)]-[sortedCentre(1,1),sortedCentre(1,2)]; % p2-p1
vecX = vecX/norm(vecX);
vectorAngle = acos(dot(vecX,vec4));

% If vector is positive y direction rotate down
if vecX(1,2) > 0
    vectorAngle = -vectorAngle;
end

if vecX(1,1) < 0
   vectorAngle = vectorAngle-pi;
end
center = [size(image, 1)/2; size(image, 2)/2];

% Rotate image
%image = imrotate(image,radtodeg(vectorAngle), 'nearest', 'crop');
greyRotated = imrotate(greyScale, radtodeg(vectorAngle), 'bilinear', 'crop');

%Crop the QR-code, first draw lines outside the code. Rotate the
%centrepoints aswell

rotationMatrix = [cos(vectorAngle), -sin(vectorAngle); sin(vectorAngle), cos(vectorAngle)];

rotatedCentrePoints = sortedNrPoints(1:3, 2:3);

rotatedCentrePoints = sortrows(rotatedCentrePoints, 1);
if rotatedCentrePoints(2, 2) < rotatedCentrePoints(1, 2)
   temp = rotatedCentrePoints(1,:);
   rotatedCentrePoints(1,:) = rotatedCentrePoints(2, :);
   rotatedCentrePoints(2,:) = temp;
end
for i = 1:3    
    result = [rotatedCentrePoints(i, 1); rotatedCentrePoints(i, 2)];
    result = rotationMatrix*(result-center)+center;
    rotatedCentrePoints(i, 1) = result(1,1);
    rotatedCentrePoints(i, 2) = result(2,1);
end


%Fix the perspective in separate file
croppedQr = fixPerspective(greyRotated, rotatedCentrePoints);


qrImage = croppedQr;