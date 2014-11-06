function [qrImage] = findQR(image)
%Function for finding and extracting the QR-code

%Check dimension and normalize image
imageDim = size(image, 3);
disp(sprintf('Dimension of image is %d', imageDim))

greyScale = im2double(image);

%Create greyscale image if the image is in color
if imageDim == 3
   greyScale = (greyScale(:,:,1)+greyScale(:,:,2)+greyScale(:,:,3))/3;
end
binary = binarize(greyScale);

imshow(binary);

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
              %fprintf('\n \n Possible found y \n \n'); 
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
           if abs(leftWhite-leftBlack) < percentage*leftWhite && abs(rightWhite-rightBlack) < percentage*rightWhite
              %fprintf('\n \n Possible found x \n \n'); 
              greyScale(segmentsX(i-2, 2):segmentsX(i+2, 2), segmentsX(i-2, 3):segmentsX(i+2, 3)) = 1;
           end
        end
    end 
end

figure
imshow(greyScale);
qrImage = zeros(200);