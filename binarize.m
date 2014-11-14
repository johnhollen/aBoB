function [binary] = binarize(image)
%BINARIZE used adaptive binarization to create binary image

%Extract width and height from the image
width = size(image, 2);
height = size(image, 1);

%Create binary image with adaptive tresholding
%Extension of Wellner's method
binaryImage = zeros(height, width);
%Calculate integral image, matlab built in method
integImage = integralImage(image);

%s is the block size
%t is a percentage
s = round(width/8, 0);
t = 15;
sdiv = floor(s/2);

%Treshold

i = 1:1:height;
j = 1:1:width;

x1 = i - sdiv;
if x1 <= 1
   x1 = 2;
end
x2 = i + sdiv;
if x2 > height+1
  x2 = height+1;
end
y1 = j - sdiv;
if y1 <= 1
   y1 = 2;
end
y2 = j + sdiv;
if y2 > width+1
  y2 = width+1;
end

count = (x2 - x1)'*(y2 - y1);
count

sum = integImage(x2, y2)-integImage(x2, y1-1)-integImage(x1-1, y2)+integImage(x1-1, y1-1);

if (image(i,j)*count) <= ((sum*(100-t))*0.01)
   binaryImage(i, j) = 0;
else
   binaryImage(i, j) = 1;
end



% for i = 1:height
%    for j = 1:width
%        x1 = i - sdiv;
%        if x1 <= 1
%            x1 = 2;
%        end
%        x2 = i + sdiv;
%        if x2 > height+1
%           x2 = height+1;
%        end
%        y1 = j - sdiv;
%        if y1 <= 1
%            y1 = 2;
%        end
%        y2 = j + sdiv;
%        if y2 > width+1
%           y2 = width+1;
%        end
% 
%        count = (x2 - x1)*(y2 - y1);
%        sum = integImage(x2, y2)-integImage(x2, y1-1)-integImage(x1-1, y2)+integImage(x1-1, y1-1);
% 
%        if (image(i,j)*count) <= ((sum*(100-t))*0.01)
%            binaryImage(i, j) = 0;
%        else
%            binaryImage(i, j) = 1;
%        end
%             
%    end
% end
binary = binaryImage;

