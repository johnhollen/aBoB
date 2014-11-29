function [straightenedImage] = fixPerspective(inImage, cornerPoints,centreWeight)
%This file will straighten up the image


cornerPoints(1,:) = [cornerPoints(1,2)-centreWeight,cornerPoints(1,1)-centreWeight];
cornerPoints(2,:) = [cornerPoints(2,2)+centreWeight,cornerPoints(2,1)-centreWeight];
cornerPoints(3,:) = [cornerPoints(3,2)-centreWeight,cornerPoints(3,1)+centreWeight];
% 
% figure
% imshow(inImage);
% hold on
% plot(cornerPoints(1,1),cornerPoints(1,2),'ro','linewidth',3);
% plot(cornerPoints(2,1),cornerPoints(2,2),'ro','linewidth',3);
% plot(cornerPoints(3,1),cornerPoints(3,2),'ro','linewidth',3);

%Fix the perspective in the image 



%% Calculate width?
width = norm(cornerPoints(2,:)-cornerPoints(1,:));
height = norm(cornerPoints(3,:)-cornerPoints(1,:));

% blackCount = zeros(3, 2);
% search = true;

inBinary = binarize(inImage);
%tresh = graythresh(inImage);
%inBinary = im2bw(inImage, tresh);

%Count the black in the corners

% %Rows
% for i = 1:length(cornerPoints)
%    row = floor(cornerPoints(i, 1));
%    col = floor(cornerPoints(i, 2));
%    blackCounterRow = 0;
%      
%    %Loop in positive direction
%    while search
%        if inBinary(row, col) == inBinary(row+1, col);
%           blackCounterRow = blackCounterRow+1;
%           row = row+1;
%        else
%           search = false;
%        end
%    end
% 
%    search = true;
%    row = floor(cornerPoints(i, 1));
%    %Loop in negative direction
%    while search
%        if inBinary(row, col) == inBinary(row-1, col)
%           blackCounterRow = blackCounterRow+1;
%           row = row-1;
%           
%        else
%            search = false;
%        end
%    end
%    blackCount(i, 1) = blackCounterRow;
 
 diffX= floor(width/5);
 diffY= floor(height/5);
%  
% 
 width=width+2*diffX;
 height=height+2*diffY;
%  
 startPointI = cornerPoints(1,1)-diffX; 
 startPointJ = cornerPoints(1,2)-diffY;
% 
% 
% 
% 
% factor = 1.8;
% 
% startPointJ = cornerPoints(1,2)-factor*blackCount(1,2);
% startPointI = cornerPoints(1,1)-factor*blackCount(1,1);
% 
% width = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)-factor*blackCount(2,1)]-[startPointJ, startPointI];
% width = norm(width);
% height = [cornerPoints(3,2)-factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)]-[startPointJ, startPointI];
% height = norm(height);
% 
 croppedImage = imcrop(inImage, [startPointI, startPointJ, width, height]);
% 
%    search = true;
% end
% 
% factor = 7/6;
% 
% startPointJ = cornerPoints(1,2)-factor*blackCount(1,2);
% startPointI = cornerPoints(1,1)-factor*blackCount(1,1);
% 
% movedCornerPoints(1,1) = cornerPoints(1,1)-factor*blackCount(1,1);
% movedCornerPoints(1,2) = cornerPoints(1,2)-factor*blackCount(1,2);
% movedCornerPoints(2,1) = cornerPoints(2,1)-factor*blackCount(2,1);
% movedCornerPoints(2,2) = cornerPoints(2,2)+factor*blackCount(2,2);
% movedCornerPoints(3,1) = cornerPoints(3,1)+factor*blackCount(3,1);
% movedCornerPoints(3,2) = cornerPoints(3,2)-factor*blackCount(3,2);
% 
% row = floor(movedCornerPoints(1,1));
% col = floor(movedCornerPoints(1,2));
% while inBinary(row,col) == 0
%     movedCornerPoints(1,1) = row;
%     movedCornerPoints(1,2) = col;
%     
%     row = row-1;
%     col = col-1;
% end
% 
% 
% row = floor(movedCornerPoints(2,1));
% col = floor(movedCornerPoints(2,2));
% while inBinary(row,col) == 0
%     movedCornerPoints(2,1) = row;
%     movedCornerPoints(2,2) = col;
%     
%     row = row-1;
%     col = col+1;
% end

if size(croppedImage, 1) > size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'bicubic'); diff = diffX;
elseif size(croppedImage, 1) < size(croppedImage, 2)
   croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'bicubic'); diff = diffY;
else
    diff=diffX;
end

[corners,AP] = findCorners2(croppedImage,diff);
newCorners = corners;
 %figure
 %imshow(croppedImage);
% hold on
% plot(corners(1,2),corners(1,1),'ro','linewidth',3);
% plot(corners(2,2),corners(2,1),'bo','linewidth',3);
% plot(corners(3,2),corners(3,1),'go','linewidth',3);
% plot(corners(4,2),corners(4,1),'co','linewidth',3);


movingpoints=[corners(1,:) ; corners(3,:) ; corners(2,:) ; corners(4,:)];
fixedpoints=[1 1;1 length(croppedImage);length(croppedImage) 1;length(croppedImage) length(croppedImage)];

%plot(1,1,'mo','linewidth',3);
%plot(1,length(croppedImage),'mo','linewidth',3);
%plot(length(croppedImage),1,'mo','linewidth',3);
%plot(length(croppedImage),length(croppedImage),'mo','linewidth',3);

tform = fitgeotrans(movingpoints,fixedpoints,'projective');
newcroppedImage = imwarp(croppedImage,tform, 'bicubic', 'fillvalues', 0);
%figure;
%imshow(newcroppedImage);

% row = floor(movedCornerPoints(3,1));
% col = floor(movedCornerPoints(3,2));
% while inBinary(row,col) == 0
%     movedCornerPoints(3,1) = row;
%     movedCornerPoints(3,2) = col;
%     
%     row = row+1;
%     col = col-1;
% end

%*****************PLOTS*****************
%figure, imshow(inBinary)
%hold on
% plot(startPointJ, startPointI, 'cx', 'linewidth', 2)
% plot(cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)-factor*blackCount(2,1), 'cx', 'linewidth', 2)
% plot(cornerPoints(3,2)-factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1), 'gx', 'linewidth', 2)
% 
% plot(cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)+factor*blackCount(2,1), 'mx', 'linewidth', 2)
% plot(cornerPoints(3,2)+factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1), 'mx', 'linewidth', 2)
%*************END PLOTS*****************


% tempCorner2 = [cornerPoints(2,2)+factor*blackCount(2,2), cornerPoints(2,1)+factor*blackCount(2,1)];
% tempCorner3 = [cornerPoints(3,2)+factor*blackCount(3,2), cornerPoints(3,1)+factor*blackCount(3,1)];

% %Refine the new corners to get a better line
% if inBinary(floor(tempCorner2(2)), floor(tempCorner2(1))) == 1
%     i = floor(tempCorner2(2)); 
%     j = floor(tempCorner2(1));
%     while inBinary(i, j) == 1
%         j = j-1;
%         i = i-1;
%         tempCorner2(1) = j;
%         tempCorner2(2) = i;         
%     end
% end
% 
% if inBinary(floor(tempCorner3(2)), floor(tempCorner3(1))) == 1
%     i = floor(tempCorner3(2)); 
%     j = floor(tempCorner3(1));
%     while inBinary(i, j) == 1
%         i = i-1;
%         j = j-1;
%         tempCorner3(2) = i;
%         tempCorner3(1) = j;
%     end
% end


%Crop the white from the transformed image and find the alignment pattern!
%[newCorners,alignmentCenter] = findCorners2(newcroppedImage,diff);

%onlyQR = imcrop(newcroppedImage,...
%    [newCorners(1,1), newCorners(1,2), norm(newCorners(1,:)-newCorners(3,:)), norm(newCorners(1,:)-newCorners(2,:))]);


onlyQR = newcroppedImage;
thresh = graythresh(onlyQR);

%onlyQR = im2bw(onlyQR, thresh);
%onlyQR = bwmorph(onlyQR, 'erode');

%figure, imshow(onlyQR)

%straightenedImage = zeros(13,13);%onlyQR;

% plot(tempCorner2(1), tempCorner2(2), 'bx', 'linewidth', 3)
% plot(tempCorner3(1), tempCorner3(2), 'bx', 'linewidth', 3)
% plot(movedCornerPoints(1,2), movedCornerPoints(1,1), 'rx', 'linewidth', 3)
% plot(movedCornerPoints(2,2), movedCornerPoints(2,1), 'rx', 'linewidth', 3)
% plot(movedCornerPoints(3,2), movedCornerPoints(3,1), 'rx', 'linewidth', 3)

%Calculate intersections
% Starting points in first row, ending points in second row
% x = [movedCornerPoints(2,2) movedCornerPoints(3,2)-factor*blackCount(3,2);...
%     tempCorner2(1) tempCorner3(1)];
% 
% y = [movedCornerPoints(2,1) movedCornerPoints(3,1);...
%     tempCorner2(2) tempCorner3(2)];
% 
% dx = diff(x);  %# Take the differences down each column
% dy = diff(y);
% den = dx(1)*dy(2)-dy(1)*dx(2);  %# Precompute the denominator
% ua = (dx(2)*(y(1)-y(3))-dy(2)*(x(1)-x(3)))/den;
% ub = (dx(1)*(y(1)-y(3))-dy(1)*(x(1)-x(3)))/den;
% 
% xi = x(1)+ua*dx(1);
% yi = y(1)+ua*dy(1);
% 
% O = [movedCornerPoints(2,2); movedCornerPoints(2,1)] - [movedCornerPoints(3,2); movedCornerPoints(3,1)];
% 
% d1 = tempCorner2' - [movedCornerPoints(2,2); movedCornerPoints(2,1)];
% d1 = d1/norm(d1);
% d2 = tempCorner3' - [movedCornerPoints(3,2); movedCornerPoints(3,1)];
% d2 = d2/norm(d2);
% 
% D = [d2 -d1];
% Dinv = inv(D);
% 
% t = D\O;

% fourthCorner = [movedCornerPoints(2,2); movedCornerPoints(2,1)]+d1*t(2);
% plot(fourthCorner(1), fourthCorner(2), 'bo', 'linewidth', 3)
% plot(xi, yi, 'ro', 'linewidth', 3)
% plot(xi, fourthCorner(2), 'co', 'linewidth', 3);

%fourthCorner = [xi, yi];

% cellHeight = ((blackCount(1,1)+blackCount(2,1)+blackCount(3,1))/3)/3;
% cellWidth = ((blackCount(1,2)+blackCount(2,2)+blackCount(3,2))/3)/3;
% 
% %Continue here
% movingPoints = [startPointJ, startPointI; corner2; corner3; fourthCorner];
% 
% moveFactorX = ceil(cellWidth*41);
% moveFactorY = ceil(cellHeight*41);
% 
% fixedPoints = [startPointJ startPointI; startPointJ+moveFactorX startPointI;...
%     startPointJ startPointI+moveFactorY; startPointJ+moveFactorX startPointI+moveFactorY];
% 
% tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
% 
% warpedImage = imwarp(inImage, tform, 'bicubic', 'outputview', imref2d(size(inImage)));
% 
% figure, imshow(warpedImage)
% hold on
% plot(startPointJ, startPointI, 'ro', 'linewidth', 3)
% plot(corner2(2), corner2(1), 'ro', 'linewidth', 3)
% plot(corner3(2), corner3(1), 'ro', 'linewidth', 3)
% 
% 
% width = norm([startPointJ, startPointI]-[startPointJ+moveFactorX, startPointI]);
% height = norm([startPointJ, startPointI]-[startPointJ, startPointI+moveFactorY]);
% 
% 
% croppedImage = imcrop(warpedImage, [startPointJ, startPointI, width, height]);
% figure, imshow(croppedImage)

%Now, fix the perspective

% if size(croppedImage, 1) > size(croppedImage, 2)
%    croppedImage = imresize(croppedImage, [size(croppedImage, 1) size(croppedImage, 1)], 'bicubic');
% elseif size(croppedImage, 1) < size(croppedImage, 2)
%    croppedImage = imresize(croppedImage, [size(croppedImage, 2) size(croppedImage, 2)], 'bicubic');
% end
% 
% [corners,AP] = findCorners(croppedImage);
% newCorners = corners;
% 
% movingpoints=[corners(1,:) ; corners(2,:) ; corners(3,:) ; corners(4,:)];
% fixedpoints=[1 1;1 length(croppedImage);length(croppedImage) 1;length(croppedImage) length(croppedImage)];
% 
% tform = fitgeotrans(movingpoints,fixedpoints,'projective');
% newcroppedImage = imwarp(croppedImage,tform, 'bicubic', 'fillvalues', 1);
% 
% if size(newcroppedImage, 1) > size(newcroppedImage, 2)
%    newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 1) size(newcroppedImage, 1)], 'bicubic');
% elseif size(newcroppedImage, 1) < size(newcroppedImage, 2)
%    newcroppedImage = imresize(newcroppedImage, [size(newcroppedImage, 2) size(newcroppedImage, 2)], 'bicubic');
% end
% 
% %Crop the white from the transformed image and find the alignment pattern!
% [newCorners,alignmentCenter] = findCorners(newcroppedImage);
% 
% onlyQR = imcrop(newcroppedImage,...
%     [newCorners(1,1), newCorners(1,2), norm(newCorners(1,:)-newCorners(3,:)), norm(newCorners(1,:)-newCorners(2,:))]);
% 
% thresh = graythresh(onlyQR);
% 
% onlyQR = im2bw(onlyQR, thresh);
% onlyQR = bwmorph(onlyQR, 'erode');
% 
% figure, imshow(onlyQR)

straightenedImage = zeros(200);

