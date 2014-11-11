function [qrImage] = findQR(image)
%Function for finding and extracting the QR-code
image = im2double(image);
%Check dimension and normalize image
imageDim = size(image, 3);
disp(sprintf('Dimension of image is %d', imageDim))

greyScale = im2double(image);

%Create greyscale image if the image is in color
if imageDim == 3
   greyScale = (greyScale(:,:,1)+greyScale(:,:,2)+greyScale(:,:,3))/3;
end
binary = binarize(greyScale);

%Find the finder pattern
%Look for ratio 1:1:3:1:1
height = size(binary, 1);
width = size(binary, 2);

segmentsY = [];
segmentSizeY = 0;
segmentY = 0;

segmentsX = [];
segmentSizeX = 0;
segmentX = 0;


%Check Horizontaly and Vertically
for j = 1:width-1
    for i = 1:height-1        
        %Vertically
        if binary(i, j) == binary(i+1,j)
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

% Save last dot in the finding pattern
findpattern = zeros(height,width);
counter = 0;

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

percentage = 0.4;

edgesY = [];
edgesX = [];
%Check the dark areas Vertically
counterY = 0;
for i = 1:length(segmentsY)-3
    if segmentsY(i, 4) == 0 && i > 3

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
              findpattern(segmentsY(i-2, 2):segmentsY(i+2, 2), segmentsY(i-2, 3):segmentsY(i+2, 3)) = 1;
              edgesY(counterY, 1) = segmentsY(i-3, 2);
              edgesY(counterY, 2) = segmentsY(i-3, 3);
              edgesY(counterY, 3) = segmentsY(i+3, 2);
              edgesY(counterY, 4) = segmentsY(i+3, 3);
              edgesY(counterY, 5) = i;
           end
        end
    end
end

counterX = 0;
for i = 1:length(segmentsX)-2
   if segmentsX(i, 4) == 0 && i > 2
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
              findpattern(segmentsX(i-2, 2):segmentsX(i+2, 2), segmentsX(i-2, 3):segmentsX(i+2, 3)) = 1;
              edgesX(counterX, 1) = segmentsX(i-3, 2);
              edgesX(counterX, 2) = segmentsX(i-3, 3);
              edgesX(counterX, 3) = segmentsX(i+3, 2);
              edgesX(counterX, 4) = segmentsX(i+3, 3);
              edgesX(counterX, 5) = i;
           end
        end
    end 
end

[Labels ,nrLabels] = bwlabel(findpattern, 4);

fprintf('Numer of labels: %d \n', nrLabels);

%Find centrepoints
nrPoints = [];
for i = 1:nrLabels
   [row, col] = find(Labels == i);
   
   meanX = mean(col);
   meanY = mean(row);
   
   nr = length(row)*length(col);
   nrPoints(i, 1) = nr;
   nrPoints(i, 2) = meanY;
   nrPoints(i, 3) = meanX;
end

[~, order1] = sort(nrPoints(:,1), 'descend');
sortedNrPoints = nrPoints(order1, :);
sortedNrPoints = sortedNrPoints(1:3, 1:3);

realedgeX = zeros(3,4);
realedgeY = zeros(3,4);
% Find edge again...

for n=1:length(edgesX)
   for z=1:3
       if edgesX(n,1) <= sortedNrPoints(z,1) 
           realedgeX(z,1) = edgesX(n,1);
           realedgeX(z,2) = edgesX(n,2);
           realedgeX(z,3) = edgesX(n,3);
           realedgeX(z,4) = edgesX(n,4);
       end
   end
end

for n=1:length(edgesY)
    for z=1:3
       if edgesY(n,2) >= sortedNrPoints(z,2) 
           realedgeY(z,1) = edgesY(n,1);
           realedgeY(z,2) = edgesY(n,2);
           realedgeY(z,3) = edgesY(n,3);
           realedgeY(z,4) = edgesY(n,4);
       end
   end
end
figure
imshow(image)
hold on
realedgeX
for i = 1:3
   plot(realedgeY(i, 2), realedgeY(i, 1), 'ro', 'linewidth', 3); 
   plot(realedgeY(i, 4), realedgeY(i, 3), 'ro', 'linewidth', 3);
   
   plot(realedgeX(i, 2), realedgeX(i, 1), 'bo', 'linewidth', 3); 
   plot(realedgeX(i, 4), realedgeX(i, 3), 'bo', 'linewidth', 3);
end
    
% ROTATING THE IMAGE 
vec4 = [1,0];
% find the two points with lowest Y-coord to create a vector
[~, order] = sort(sortedNrPoints(:,3));
sortedCentre = sortedNrPoints(order,:);
sortedCentre = sortedCentre(1:2,2:3);

% Check which of the two remaining points who have highest x-coord in order
% to get right direction of vector
[~, order] = sort(sortedCentre(:,2),'descend');
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
image = imrotate(image,radtodeg(vectorAngle), 'bilinear', 'crop');
binaryRotated = imrotate(binary, radtodeg(vectorAngle), 'bilinear', 'crop');

%figure 
%imshow(binaryRotated);
%hold on

%Crop the QR-code, first draw lines outside the code. Rotate the
%centrepoints aswell

rotationMatrix = [cos(vectorAngle), -sin(vectorAngle); sin(vectorAngle), cos(vectorAngle)];

rotatedCentrePoints = sortedNrPoints(1:3, 2:3);

for i = 1:3    
    result = [rotatedCentrePoints(i, 1); rotatedCentrePoints(i, 2)];
    result = rotationMatrix*(result-center)+center;
    rotatedCentrePoints(i, 1) = result(1,1);
    rotatedCentrePoints(i, 2) = result(2,1);
end

%plot([rotatedCentrePoints(1,2),rotatedCentrePoints(2, 2)], [rotatedCentrePoints(1,1),rotatedCentrePoints(2, 1)],'g-', 'linewidth', 3)
%plot([rotatedCentrePoints(3,2),rotatedCentrePoints(2, 2)], [rotatedCentrePoints(3,1),rotatedCentrePoints(2, 1)],'g-', 'linewidth', 3)
%plot([rotatedCentrePoints(1,2),rotatedCentrePoints(3, 2)], [rotatedCentrePoints(1,1),rotatedCentrePoints(3, 1)],'g-', 'linewidth', 3)

%Extract the QR-code

qrImage = zeros(200);