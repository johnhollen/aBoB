% Main file for testing tnm034 function 
clc
fprintf('\nStart main \n========================================================== \n\n');

close all


img = imread('testImages/Images_Training_1/Bygg_1.png');
img2 = imread('testImages/Images_Training_1/Bygg_1a.png');
img3 = imread('testImages/Images_Training_1/Bygg_1b.png');
img4 = imread('testImages/Images_Training_1/Bygg_1c.png');
img5 = imread('testImages/Images_Training_1/Bygg_1d.png');
img6 = imread('testImages/Images_Training_1/Bygg_1e.png');
img7 = imread('testImages/Images_Training_1/Bygg_2.png');
img8 = imread('testImages/Images_Training_1/Bygg_2a.png');
img9 = imread('testImages/Images_Training_1/Bygg_2b.png');
img10 = imread('testImages/Images_Training_1/Bygg_2c.png');
img11 = imread('testImages/Images_Training_1/Bygg_2d.png');
img12 = imread('testImages/Images_Training_1/Bygg_2e.png');
img13 = imread('testImages/Images_Training_1/Bygg_3.png');
img14 = imread('testImages/Images_Training_1/Bygg_3a.png');
img15 = imread('testImages/Images_Training_1/Bygg_3b.png');
img16 = imread('testImages/Images_Training_1/Bygg_3c.png');
img17 = imread('testImages/Images_Training_1/Bygg_3d.png');
img18 = imread('testImages/Images_Training_1/Bygg_3e.png');
img19 = imread('testImages/Images_Training_1/Bygg_4.png');
img20 = imread('testImages/Images_Training_1/Bygg_4a.png');
img21 = imread('testImages/Images_Training_1/Bygg_4b.png');
img22 = imread('testImages/Images_Training_1/Bygg_4c.png');
img23 = imread('testImages/Images_Training_1/Bygg_4d.png');
img24 = imread('testImages/Images_Training_1/Bygg_4e.png');
img25 = imread('testImages/Husannons_full.png');
img26 = imread('../abobtest/DostojevskyMetro_full_0.png');
img27 = imread('testImages/Images_Training_2/Hus_1.png');
img28 = imread('testImages/Images_Training_2/Hus_1a.png');
img29 = imread('testImages/Images_Training_2/Hus_1b.png');
img30 = imread('testImages/Images_Training_2/Hus_1c.png');
img31 = imread('testImages/Images_Training_2/Hus_1d.png');
img32 = imread('testImages/Images_Training_2/Hus_1e.png');


% slCharacterEncoding('UTF-8');
% directory = dir('testImages');

% fileID = fopen('exp.txt','w');
% fprintf(fileID,'%6s %12s\n','x','exp(x)');
% fprintf(fileID,'%6.2f %12.8f\n',A);
% fclose(fileID);

% strOut = tnm034(img)
% strOut2 = tnm034(img2)
% strOut3 = tnm034(img3)
% strOut4 = tnm034(img4)
% strOut5 = tnm034(img5)
% strOut6 = tnm034(img6)
% strOut7 = tnm034(img7)
% strOut8 = tnm034(img8)
% strOut9 = tnm034(img9)
% strOut10 = tnm034(img10)
% strOut11 = tnm034(img11)
strOut12 = tnm034(img12)
% strOut13 = tnm034(img13)
% strOut14 = tnm034(img14)
% strOut15 = tnm034(img15)
% strOut16 = tnm034(img16)
% strOut17 = tnm034(img17)
% strOut18 = tnm034(img18)
% strOut19 = tnm034(img19)
% strOut20 = tnm034(img20)
% strOut21 = tnm034(img21)
% strOut22 = tnm034(img22)
% strOut23 = tnm034(img23)
% strOut24 = tnm034(img24)
strOut25 = tnm034(img25)
strOut26 = tnm034(img26)
% strOut27 = tnm034(img27)
% strOut28 = tnm034(img28)
% strOut29 = tnm034(img29)
% strOut30 = tnm034(img30)
% strOut31 = tnm034(img31)
% strOut32 = tnm034(img32)

% fileID = fopen('QRans.txt','w');
% fprintf(fileID,'%12s  %18s\n','Image','Text');
% 
% 
% counter=1;
% for i=1:1%length(directory)
%     folder =strcat('testImages/Images_Training_',num2str(i));
%     imagefiles = dir(folder); 
%     for j=1:length(imagefiles)
%         if(strcmp(imagefiles(j).name,'.')  || strcmp(imagefiles(j).name,'..'))
%         
%         else
%            currentfilename = imagefiles(j).name;
%            currentimage = imread(strcat(folder,'/',currentfilename));
%            
%            code = tnm034(currentimage);% String decoded
%            fprintf(fileID,'%s \t\t %12s \n \n',currentfilename,code);
%            fprintf(fileID,' --------------- \n \n');
%            %images{counter} = currentimage;
%            %counter = counter+1; 
%         end
%     end
% end
% 
% fclose(fileID);

fprintf('\n==========================================================\nStop main\n');


