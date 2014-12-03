function [corners ,allignmentCenter] = findCorners(inputImage)
%FINDCORNERS Function for finding corners in cropped Qrcode image

corner1 = zeros(1, 2);
corner2 = zeros(1, 2);
corner3 = zeros(1, 2);
corner4 = zeros(1, 2);
check = false;

thresh = graythresh(inputImage);
inBinary = im2bw(inputImage, thresh);

% figure, imshow(inputImage);
% hold on

dimz= length(inputImage);

%Corner one: Left, Up
for i=1:dimz
    if(inBinary(i, i) == 0)
       corner1 = [i, i];
       for j = i:-1:1
          %Horiz
          if inBinary(i, j) == 0
             corner1 = [j, i]; 
          end
       end
       %Verti
       for j = i:-1:1
          if inBinary(j, corner1(1)) == 0
             corner1(2) = j; 
          end
       end
       check = true;
    end
    if check
       break; 
    end
end
check = false;

%Corner2: Left, Down
otherIndex = 1;
for i=dimz:-1:1
    if(inBinary(i, otherIndex) == 0)
       corner2 = [otherIndex, i];
       for j = i:-1:1
          %Horiz
          if inBinary(i, j) == 0
             corner2 = [j, i]; 
          end
       end
       %Verti
       for j = i:dimz
          if inBinary(j, corner2(1)) == 0
             corner2(2) = j; 
          end
       end
       check = true;
    end
    if check
       break; 
    end
    otherIndex = otherIndex+1;
end
check = false;

%Corner3: Up, Right
otherIndex = dimz;
for i=1:dimz
    if(inBinary(i, otherIndex) == 0)
       corner3 = [otherIndex, i];
       for j = i:dimz
          %Horiz
          if inBinary(i, j) == 0
             corner3 = [j, i]; 
          end
       end
       %Verti
       for j = i:-1:1
          if inBinary(j, corner3(1)) == 0
             corner3(2) = j; 
          end
       end
       check = true;
    end
    if check
       break; 
    end
    otherIndex = otherIndex-1;
end
%Find the approx size of the QR-code
width = norm(corner1 - corner3);
height = norm(corner1 - corner2);

template = ones(ceil((height/41)*5), ceil((width/41))*5);

template(1+1/5*size(template, 1):size(template, 1)-1/5*size(template, 1),...
    1+1/5*size(template, 2):size(template, 2)-1/5*size(template, 2)) = 0;

template(1+2/5*size(template, 1):size(template, 1)-2/5*size(template, 1),...
    1+2/5*size(template, 2):size(template, 2)-2/5*size(template, 2)) = 1;

inputX = size(inputImage, 1); inputY = size(inputImage, 2);

searchArea = inputImage(ceil(inputX/2):inputX, ceil(inputY/2):inputY);

c = normxcorr2(template, searchArea);

[ypeak, xpeak]   = find(c==max(c(:)));
% account for padding that normxcorr2 adds
yoffSet = ypeak-size(template,1);
xoffSet = xpeak-size(template,2);


allignmentCenter = [xoffSet+(xpeak-xoffSet)/2, yoffSet+(ypeak-yoffSet)/2];

%fourthCorner = [allignmentCenter(1)+((8.5/6)*allignmentCenter(1)-allignmentCenter(1)),...
    %allignmentCenter(2)+((8.5/6)*allignmentCenter(2))-allignmentCenter(2)];

fourthCorner = allignmentCenter;

% figure, imshow(searchArea);
% hold on
% plot(fourthCorner(1), fourthCorner(2), 'rx')

fourthCorner = [inputX/2+fourthCorner(1), inputY/2+fourthCorner(2)];

corner4 = fourthCorner;



% plot(corner1(1), corner1(2), 'ro', 'linewidth', 2)
% plot(corner2(1), corner2(2), 'ro', 'linewidth', 2)
% plot(corner3(1), corner3(2), 'ro', 'linewidth', 2)
% plot(corner4(1), corner4(2), 'ro', 'linewidth', 2)
% plot(allignmentCenter(1), allignmentCenter(2), 'bo', 'linewidth', 2)
% 
% figure, imshow(template)

corners = zeros(4, 2);

corners(1, 1) = corner1(1);
corners(1, 2) = corner1(2);
corners(2, 1) = corner2(1);
corners(2, 2) = corner2(2);
corners(3, 1) = corner3(1);
corners(3, 2) = corner3(2);
corners(4, 1) = fourthCorner(1);
corners(4, 2) = fourthCorner(2);





