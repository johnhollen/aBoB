% Main file for testing tnm034 function 
close all
clc

fprintf('\nStart main \n========================================================== \n\n');

% img = imread('testImages/Images_Training_1/Bygg_1.png');
% img2 = imread('testImages/Images_Training_1/Bygg_1a.png');
% img3 = imread('testImages/Images_Training_1/Bygg_1b.png');
% img4 = imread('testImages/Images_Training_1/Bygg_1c.png');
% img5 = imread('testImages/Images_Training_1/Bygg_1d.png');
% img6 = imread('testImages/Images_Training_1/Bygg_1e.png');
% img7 = imread('testImages/Images_Training_1/Bygg_2.png');
% img8 = imread('testImages/Images_Training_1/Bygg_2a.png');
% img9 = imread('testImages/Images_Training_1/Bygg_2b.png');
% img10 = imread('testImages/Images_Training_1/Bygg_2c.png');
% img11 = imread('testImages/Images_Training_1/Bygg_2d.png');
% img12 = imread('testImages/Images_Training_1/Bygg_2e.png');
% img13 = imread('testImages/Images_Training_1/Bygg_3.png');
% img14 = imread('testImages/Images_Training_1/Bygg_3a.png');
% img15 = imread('testImages/Images_Training_1/Bygg_3b.png');
% img16 = imread('testImages/Images_Training_1/Bygg_3c.png');
% img17 = imread('testImages/Images_Training_1/Bygg_3d.png');
% img18 = imread('testImages/Images_Training_1/Bygg_3e.png');
% img19 = imread('testImages/Images_Training_1/Bygg_4.png');
% img20 = imread('testImages/Images_Training_1/Bygg_4a.png');
% img21 = imread('testImages/Images_Training_1/Bygg_4b.png');
% img22 = imread('testImages/Images_Training_1/Bygg_4c.png');
% img23 = imread('testImages/Images_Training_1/Bygg_4d.png');
% img24 = imread('testImages/Images_Training_1/Bygg_4e.png');
% img25 = imread('testImages/Husannons_full.png');
% %img26 = imread('../abobtest/DostojevskyMetro_full_0.png');
% img27 = imread('testImages/Images_Training_2/Hus_1.png');
% img28 = imread('testImages/Images_Training_2/Hus_1a.png');
% img29 = imread('testImages/Images_Training_2/Hus_1b.png');
% img30 = imread('testImages/Images_Training_2/Hus_1c.png');
% img31 = imread('testImages/Images_Training_2/Hus_1d.png');
% img32 = imread('testImages/Images_Training_2/Hus_1e.png');
slCharacterEncoding('UTF-8');
directory = dir('testImages');

% fileID = fopen('exp.txt','w');
% fprintf(fileID,'%6s %12s\n','x','exp(x)');
% fprintf(fileID,'%6.2f %12.8f\n',A);
% fclose(fileID);

fileID = fopen('QRans.txt','w');
fprintf(fileID,'%12s  %18s\n','Image','Text');

counter=1;
for i=1:1%length(directory)
    folder =strcat('testImages/Images_Training_',num2str(i));
    imagefiles = dir(folder); 
    for j=1:length(imagefiles)
        if(strcmp(imagefiles(j).name,'.')  || strcmp(imagefiles(j).name,'..'))
        
        else
           currentfilename = imagefiles(j).name;
           currentimage = imread(strcat(folder,'/',currentfilename));
           
           code = tnm034(currentimage);% String decoded
           fprintf(fileID,'%s \t\t %12s \n \n',currentfilename,code);
           fprintf(fileID,' --------------- \n \n');
           %images{counter} = currentimage;
           %counter = counter+1; 
        end
    end
end

fclose(fileID);

fprintf('\n==========================================================\nStop main\n');


