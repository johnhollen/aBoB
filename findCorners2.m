function [corners ,allignmentCenter] = findCorners2(inputImage,diff)
%FINDCORNERS Function for finding corners in cropped Qrcode image

dimz= length(inputImage);

% Start corner detection by approximate the corners..
corners = zeros(4,2);
betterCorners = zeros(3,2);
corners(1,:) = [diff,diff];
corners(2,:) = [dimz-diff,diff];
corners(3,:) = [diff,dimz-diff];

checkArea = dimz/25; % 4% checkarea around approximated corners
%Extract small areas to find more accurate corners
for i=1:3
    area = inputImage(corners(i,2)-checkArea:corners(i,2)+checkArea,...
            corners(i,1)-checkArea:corners(i,1)+checkArea);
    %figure
    %imshow(area);
    %tempCorn =detectMinEigenFeatures(area);
    betterCorners(i,:)=corner(area,'Harris',1);
    
    %hold on
    %plot(checkArea,checkArea,'go','linewidth',3);
    %plot(betterCorners(i,1),betterCorners(i,2),'ro','linewidth',3);
    betterCorners(i,:) = betterCorners(i,:)-[checkArea,checkArea]; 
end
betterCorners=round(betterCorners,0);


% Convert from local coords to image coord
corners(1,1)=corners(1,1)+betterCorners(1,2);
corners(1,2)=corners(1,2)+betterCorners(1,1);
    
corners(2,1)=corners(2,1)+betterCorners(3,2);
corners(2,2)=corners(2,2)+betterCorners(3,1);
    
corners(3,1)=corners(3,1)+betterCorners(2,2);
corners(3,2)=corners(3,2)+betterCorners(2,1);


thresh = graythresh(inputImage);
inBinary = im2bw(inputImage, thresh);



corner1 = corners(1,:);
corner2 = corners(2,:);
corner3 = corners(3,:);
hej=1;
% Safety check for the three corners


checkArea = round(checkArea,0)

checkArea=checkArea/1.5;
% Correction of corners!!
for n=1:3
    switch(n)
        % First corner
        case 1
         while(corners(1,2)-checkArea>0) 
            while(corners(1,1)-checkArea>0)
                % If sum of all pixel from corner(1,1) and 4 % to left > 0
                % go one step left..

               if(sum(inBinary(corners(1,1)-checkArea:corners(1,1),corners(1,2))) < checkArea)
                   corners(1,1)=corners(1,1)-1; 
               else
                   corners(1,1)=corners(1,1)+1; 
                   break;
               end
            end
             % If sum of all pixel from corner(1,2) and 4 % to up > 0
                % go one step left..
               if(sum(inBinary(corners(1,1),corners(1,2)-checkArea:corners(1,2))) < checkArea)
                   corners(1,2)=corners(1,2)-1; 
               else
                   corners(1,2)=corners(1,2)+1; 
                   break;
               end
            
         end
        % Second corner
        case 2
        while(corners(2,2)-checkArea > 0) 
            while(corners(2,1)+checkArea <= dimz)
                
               % Walk down 
               if(sum(inBinary(corners(2,1):corners(2,1)+checkArea,corners(2,2))) < checkArea)
                   corners(2,1)=corners(2,1)+1; 
               else
                   corners(2,1)=corners(2,1)-1;
                   break;
               end
            end
             %Walk left
               if(sum(inBinary(corners(2,1),corners(2,2)-checkArea:corners(2,2))) < checkArea)
                   corners(2,2)=corners(2,2)-1; 
               else
                   corners(2,2)=corners(2,2)+1;
                   break;
               end
            
        end
        % Third corner    
        case 3
        while(corners(2,2)+checkArea <= dimz) 
            while(corners(2,1)-checkArea > 0)
                
               % Walk up 
               if(sum(inBinary(corners(3,1)-checkArea:corners(3,1),corners(3,2))) < checkArea)
                   corners(3,1)=corners(3,1)-1; 
               else
                   corners(3,1)=corners(3,1)+1;
                   break;
               end
            end
             %Walk right
               if(sum(inBinary(corners(3,1),corners(3,2):corners(3,2)+checkArea)) < checkArea)
                   corners(3,2)=corners(3,2)+1; 
               else
                   corners(3,2)=corners(3,2)-1;
                   break;
               end
        end          
    end
end

figure
imshow(inBinary);
hold on
plot(corners(1,2),corners(1,1),'ro','linewidth',3);
plot(corners(2,2),corners(2,1),'bo','linewidth',3);
plot(corners(3,2),corners(3,1),'co','linewidth',3);

%Find the approx size of the QR-code

width = norm(corner1 - corner3);
height = norm(corner1 - corner2);

template = ones(ceil((height/41)*5), ceil((width/41))*5);

template(1+1/5*size(template, 1):size(template, 1)-1/5*size(template, 1),...
    1+1/5*size(template, 2):size(template, 2)-1/5*size(template, 2)) = 0;

template(1+2/5*size(template, 1):size(template, 1)-2/5*size(template, 1),...
    1+2/5*size(template, 2):size(template, 2)-2/5*size(template, 2)) = 1;

c = normxcorr2(template,inputImage);

[ypeak, xpeak]   = find(c==max(c(:)));
% account for padding that normxcorr2 adds
yoffSet = ypeak-size(template,1);
xoffSet = xpeak-size(template,2);

% figure, imshow(inputImage)
% hold on
% plot(xoffSet + (xpeak-xoffSet)/2, yoffSet + (ypeak-yoffSet)/2, 'ro', 'linewidth', 3)
% plot(corner1(1), corner1(2), 'ro', 'linewidth', 3)
% plot(corner2(1), corner2(2), 'ro', 'linewidth', 3)
% plot(corner3(1), corner3(2), 'ro', 'linewidth', 3)


allignmentCenter = [xoffSet+(xpeak-xoffSet)/2, yoffSet+(ypeak-yoffSet)/2];

fourthCorner = [allignmentCenter(1)+((7/6)*allignmentCenter(1)-allignmentCenter(1)),...
    allignmentCenter(2)+((7/6)*allignmentCenter(2))-allignmentCenter(2)];

%plot(fourthCorner(1), fourthCorner(2), 'bo', 'linewidth', 3)

corners(4, 1) = fourthCorner(1);
corners(4, 2) = fourthCorner(2);





