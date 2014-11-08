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
%Check the dark areas Vertically
for i = 1:length(segmentsY)-2
    if segmentsY(i, 4) == 0 && i > 2

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
              findpattern(segmentsY(i-2, 2):segmentsY(i+2, 2), segmentsY(i-2, 3):segmentsY(i+2, 3)) = 1;
              greyScale(segmentsY(i-2, 2):segmentsY(i+2, 2), segmentsY(i-2, 3):segmentsY(i+2, 3)) = 1;
           end
        end
    end
end

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
           %Check edges
           counter = counter+1;
           if abs(leftWhite-leftBlack) < percentage*leftWhite && abs(rightWhite-rightBlack) < percentage*rightWhite
              findpattern(segmentsX(i-2, 2):segmentsX(i+2, 2), segmentsX(i-2, 3):segmentsX(i+2, 3)) = 1;
              greyScale(segmentsX(i-2, 2):segmentsX(i+2, 2), segmentsX(i-2, 3):segmentsX(i+2, 3)) = 1;
           end
        end
    end 
end

[Labels ,nrLabels] = bwlabel(findpattern, 4);

%Labels = Labels/max(max(Labels));

fprintf('Numer of labels: %d \n', nrLabels);

%area1 = zeros(count,3);
%countX=0;
%countY=0;
%%% Calculate the centre point of each finding pattern
% for i=1:height
%     for j=1:width
%         for x=1:count
%             if(L(j,i)==x)
%                area1(x,1) = area1(x,1) + i;
%                area1(x,2) = area1(x,2) + j;
%                area1(x,3) = area1(x,3) + 1;
%             end
%         end  
%     end
% end
% 
% 
%  for x=1:count
%       middlepoint(x,1) = area1(x,1)/area1(x,3);
%       middlepoint(x,2) = area1(x,2)/area1(x,3);
%  end 
% 
% round(middlepoint)

%figure
%imshow(L);


centrePoints = zeros(3,2);

counter = 0;
figure
imshow(image)
hold on

%Find centrepoints
nrPoints = [];
for i = 1:nrLabels
   [row, col] = find(Labels == i);
   
   meanX = round(mean(col), 0);
   meanY = round(mean(row), 0);
   
   nr = length(row)*length(col);
   nrPoints(i, 1) = nr;
   nrPoints(i, 2) = meanY;
   nrPoints(i, 3) = meanX;
end


[values1, order1] = sort(nrPoints(:,1), 'descend');
sortedNrPoints = nrPoints(order1, :);
sortedNrPoints = sortedNrPoints(1:3, 1:3);
sortedNrPoints

plot([sortedNrPoints(1,3),sortedNrPoints(2, 3)], [sortedNrPoints(1,2),sortedNrPoints(2, 2)],'color', 'r', 'linewidth', 3)

plot([sortedNrPoints(3,3),sortedNrPoints(2, 3)], [sortedNrPoints(3,2),sortedNrPoints(2, 2)],'color', 'r', 'linewidth', 3)

plot([sortedNrPoints(1,3),sortedNrPoints(3, 3)], [sortedNrPoints(1,2),sortedNrPoints(3, 2)],'color', 'r', 'linewidth', 3)


% ROTATING THE IMAGE 
vec4 = [1,0];
% find the two points with lowest Y-coord to create a vector
[values, order] = sort(sortedNrPoints(:,3));
sortedCentre = sortedNrPoints(order,:);
sortedCentre = sortedCentre(1:2,2:3);

% Check which of the two remaining points who have highest x-coord in order
% to get right direction of vector
[values, order] = sort(sortedCentre(:,2),'descend');
sortedCentre = sortedNrPoints(order,:);

sortedCentre

vecX = [sortedCentre(2,2),sortedCentre(2,3)]-[sortedCentre(1,2),sortedCentre(1,3)]; % p2-p1
vecX = vecX/norm(vecX);
vectorAngle = acos(dot(vecX,vec4));
vecX
% If vector is positive y direction rotate down
if vecX(1,2) > 0
    vectorAngle = -radtodeg(vectorAngle)
else
    vectorAngle = radtodeg(vectorAngle)
end

% Rotate image
image = imrotate(image,vectorAngle);

%figure 
%imshow(image);


%Extract the QR-code

qrImage = zeros(200);