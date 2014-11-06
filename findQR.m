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
figure
imshow(image);

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

percentage = 0.25;
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

%figure
%imshow(L);

% Calculate the centre point of each finding pattern we want three
centrePoints = zeros(3,2);
counter = 0;
for i = 1:nrLabels
   [row, col] = find(Labels == i);
   meanX = round(mean(col), 0);
   meanY = round(mean(row), 0);
   
   if length(row) > 1000 && length(col) > 1000
       counter = counter+1;
       if(counter > 3)
          break; 
       end        
       centrePoints(counter, 1) = meanY;
       centrePoints(counter, 2) = meanX;
   end
end

%vec1 = [centrePoints(2, 1), centrePoints(2, 2)]-[centrePoints(1, 1), centrePoints(1, 2)]
%vec2 = [centrePoints(3, 1), centrePoints(3, 2)]-[centrePoints(1, 1), centrePoints(1, 2)]
%vec3 = [centrePoints(3, 1), centrePoints(3, 2)]-[centrePoints(2, 1), centrePoints(2, 2)]
%vec1 = vec1/norm(vec1);
%vec2 = vec2/norm(vec2);
%vec3 = vec3/norm(vec3);
imshow(image)
hold on
plot([centrePoints(1,2),centrePoints(2, 2)], [centrePoints(1,1),centrePoints(2, 1)],'color', 'r', 'linewidth', 3)

plot([centrePoints(3,2),centrePoints(2, 2)], [centrePoints(3,1),centrePoints(2, 1)],'color', 'r', 'linewidth', 3)

plot([centrePoints(1,2),centrePoints(3, 2)], [centrePoints(1,1),centrePoints(3, 1)],'color', 'r', 'linewidth', 3)
%plot(vec3, 'b')
%angles
%a = acos(dot(vec2, vec1));
%b = acos(dot(vec2, vec3));
%c = acos(dot(vec1, vec3));


%Extract the QR-code




qrImage = zeros(200);