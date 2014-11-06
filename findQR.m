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

%imshow(binary);

%Find the finder pattern
%Look for ratio 1:1:3:1:1
width = size(binary, 1);
height = size(binary, 2);

segments = [];
segmentSize = 0;
segment = 0;
%figure
%imshow(image);

for j = 1:height
    for i = 1:width-1
        if binary(i, j) == binary(i+1, j)
           segmentSize = segmentSize+1;
        else
            segment = segment+1;
            segments(segment, 1) = segmentSize;
            segments(segment, 2) = i;
            segments(segment, 3) = j;
            segments(segment, 4) = binary(i,j);
            
            %if binary(i, j) == 0
             %   segments(segment, 4) = 0;
            %elseif binary(i, j) == 1
             %   segments(segment, 4) = 1;
            %end
            segmentSize = 0;
        end
    end    
end
percentage = 0.35;


% Save last dot in the finding pattern
findpattern = zeros(width,height);
counter = 0;
%Check the dark areas
for i = 1:length(segments)-2
    if segments(i, 4) == 0 && i > 2
        %fprintf('black: %d, white: %d, black: %d, white: %d, black: %d \n',segments(i-2, 1), segments(i-1, 1), segments(i, 1), segments(i+1, 1), segments(i+2, 1));
        
        middleBlack = segments(i, 1);
        leftWhite = segments(i-1, 1);
        rightWhite = segments(i+1, 1);
        leftBlack = segments(i-2, 1);
        rightBlack = segments(i+2, 1);
        
        %Check middle to adjacent
        if abs(middleBlack-3*leftWhite) <= percentage*middleBlack && abs(middleBlack-3*rightWhite) <= percentage*middleBlack
           %Check edges
           counter = counter+1;
           if abs(leftWhite-leftBlack) < percentage*leftWhite && abs(rightWhite-rightBlack) < percentage*rightWhite
              fprintf('\n \n Possible found \n \n'); 
              greyScale(segments(i-2, 2):segments(i+2, 2), segments(i-2, 3):segments(i+2, 3)) = 1;
              %findpattern(counter,1)= segments(i-2,2);  % Start x-led
              %findpattern(counter,2)= segments(i+2,2);  % Stop x-led
              %findpattern(counter,3)= segments(i-2,3);  % Start y-led
              %findpattern(counter,4)= segments(i+2,3);  % Stop y-led
              
              findpattern(segments(i-2, 2):segments(i+2, 2), segments(i-2, 3):segments(i+2, 3)) = 1;
              
           end
        end
    end
end


L = bwlabel(findpattern, 4);

L = L/max(max(L));

counter
figure
imshow(L);
qrImage = zeros(200);