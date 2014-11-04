function strout = tnm034(im) 
% 
% Im should be in double format, normalized to the interval [0,1] 
% strout: The resulting character string of the coded 
% The string must have exactly the number of characters that 
% corresponds to the information in the code. 

%Check dimension and normalize image
imageDim = size(im, 3);
disp(sprintf('Dimension of image is %d', imageDim))
im = im2double(im);

%Create greyscale image if the image is in color
if imageDim == 3
   im = (im(:,:,1)+im(:,:,2)+im(:,:,3))/3;
   %imshow(im);
end

%First step: Find the corner points, call the corresponding function
qrImage = findQR(im);

binary = binarize(im);



string = 'Tjena';

strout=char(string);