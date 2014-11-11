% Main file for testing tnm034 function 2
img = imread('testimages/Images_Training_1/Bygg_1.png');
img1 = imread('testimages/Images_Training_1/Bygg_2.png');
img2= imread('testimages/Images_Training_1/Bygg_3.png');
img3 = imread('testimages/Images_Training_1/Bygg_4.png');
img4 = imread('testimages/testbild2.jpg')

%imshow(img);
%figure
strOut = tnm034(img);
strOut = tnm034(img1);
strOut = tnm034(img2);
strOut = tnm034(img3);
strOut = tnm034(img4);

