% Main file for testing tnm034 function 
clc
fprintf('\nStart main \n========================================================== \n\n');

% close all
%img = imread('testImages/Images_Training_2/Hus_1b.png');
% img2 = imread('testImages/Images_Training_5/DostojevskyMetro_full_0.png');
%img3 = imread('testImages/Images_Training_5/Husannons_full.png');
%img4 = imread('testImages/Images_Training_6/Bygg_3_Illum.png');
% img5 = imread('testImages/Images_Training_6/Hus_1_Illum.png');
% img6 = imread('testImages/Images_Training_6/Hus_4_Illum.png');
% img7 = imread('testImages/Images_Training_6/Husannons_full_Illum.png');
%img = imread('testImages/Images_Training_3/Hus_2e.png');
% % 
%strout1 = tnm034(img)
% strout2 = tnm034(img2)
%strout3 = tnm034(img3)
%strout4 = tnm034(img4)
% strout5 = tnm034(img5)
% strout6 = tnm034(img6)
% strout7 = tnm034(img7)

slCharacterEncoding('UTF-8');
directory = dir('testImages');

fileID = fopen('QRans.txt','w');
fprintf(fileID,'%12s  %18s\n','Image','Text');


counter=1;
for i=1:length(directory)
    folder =strcat('testImages/Images_Training_',num2str(i));
    imagefiles = dir(folder); 
    for j=1:length(imagefiles)
        if(strcmp(imagefiles(j).name,'.')  || strcmp(imagefiles(j).name,'..'))
        
        else
           currentfilename = imagefiles(j).name;
           currentimage = imread(strcat(folder,'/',currentfilename));
           
           code = tnm034(currentimage);% String decoded
           fprintf(fileID,'%s \n\n%12s \n \n',currentfilename,code);
           fprintf(fileID,'--------------- \n \n');
        
        end
    end
end

fclose(fileID);

fprintf('\n==========================================================\nStop main\n');


