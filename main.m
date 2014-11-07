% Main file for testing tnm034 function 

img = imread('testImages/hardtest.jpg');
img2 = imread('testImages/Images_Training_1/Bygg_2.png');
img3 = imread('testImages/Husannons_full.png');
img4 = imread('testImages/Images_Training_1/Bygg_4.png');
%imshow(img);
%figure
strOut = tnm034(img);
strOut2 = tnm034(img2);
strOut3 = tnm034(img3);
strOut4 = tnm034(img4);

