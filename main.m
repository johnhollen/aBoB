% Main file for testing tnm034 function 
fprintf('\nStart main \n========================================================== \n\n');

img = imread('testimages/Husannons_full.png');
img2 = imread('testimages/Images_Training_1/Bygg_2e.png');
img3 = imread('testimages/Hus_3e.png');

strOut = tnm034(img)
strOut2 = tnm034(img2)
strOut3 = tnm034(img3)

fprintf('\n==========================================================\nStop main\n');


