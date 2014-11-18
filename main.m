% Main file for testing tnm034 function 
fprintf('\nStart main \n========================================================== \n\n');

img = imread('testImages/Images_Training_1/Bygg_1d.png');
%img2 = imread('testImages/Images_Training_2/Hus_1.png');

strOut = tnm034(img)
%strOut2 = tnm034(img2)

fprintf('\n==========================================================\nStop main\n');


