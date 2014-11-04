function [binary] = binarize(image)
%BINARIZE used adaptive binarization to create binary image

%Extract width and height from the image
width = size(image, 1);
height = size(image, 2);

%Create binary image with adaptive tresholding
%Extension of Wellner's method
binaryImage = zeros(width, height);
%Calculate integral image, matlab built in method
integImage = integralImage(image);

%s is the block size
%t is a percentage
s = round(width/8, 0);
fprintf('s: %d \n', s);
t = 15;

%Treshold
for i = 1:width
   for j = 1:height
       x1 = i - s/2;
       if x1 <= 1
           x1 = 2;
       end
       x2 = i + s/2;
       if x2 > width+1
          x2 = width+1;
       end
       y1 = j - s/2;
       if y1 <= 1
           y1 = 2;
       end
       y2 = j + s/2;
       if y2 > height+1
          y2 = height+1;
       end

       count = (x2 - x1)*(y2 - y1);
       sum = integImage(x2, y2)-integImage(x2, y1-1)-integImage(x1-1, y2)+integImage(x1-1,y1-1);

       if (image(i,j)*count) <= ((sum*(100-t))/100)
           binaryImage(i, j) = 0;
       else
           binaryImage(i, j) = 1;
       end
            
   end
end

imshow(binaryImage);
figure 
imshow(image);

binary = binaryImage;

