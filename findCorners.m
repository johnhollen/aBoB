function [corners ,allignmentCenter] = findCorners(inputImage)
%FINDCORNERS Function for finding corners in cropped Qrcode image

corner1 = zeros(1, 2);
corner2 = zeros(1, 2);
corner3 = zeros(1, 2);
corner4 = zeros(1, 2);
check = false;

%figure, imshow(inputImage)

thresh = graythresh(inputImage);
inBinary = im2bw(inputImage, thresh);

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
check = false;

%{
Corner4: Down, Right
for i=dimz:-1:1
    if(inputImage(i, i) == 0)
       corner4 = [i, i];
       for j = i:dimz
          if inputImage(i, j) == 0
             corner4 = [j, i]; 
          end
       end
       for j = i:dimz
          if inputImage(j, corner4(1)) == 0
             corner4(2) = j; 
          end
       end
       check = true;
    end
    if check
       break; 
    end
end
%}

%Find the approx size of the QR-code

width = norm(corner1 - corner3);
height = norm(corner1 - corner2);

template = ones(ceil((height/41)*5), ceil((width/41))*5);

template(1+1/5*size(template, 1):size(template, 1)-1/5*size(template, 1),...
    1+1/5*size(template, 2):size(template, 2)-1/5*size(template, 2)) = 0;

template(1+2/5*size(template, 1):size(template, 1)-2/5*size(template, 1),...
    1+2/5*size(template, 2):size(template, 2)-2/5*size(template, 2)) = 1;

c = normxcorr2(template,inputImage);

%figure, imshow(c)

[ypeak, xpeak]   = find(c==max(c(:)));
% account for padding that normxcorr2 adds
yoffSet = ypeak-size(template,1);
xoffSet = xpeak-size(template,2);

%figure, imshow(template);


%figure, imshow(inputImage)
%hold on
%plot(xoffSet + (xpeak-xoffSet)/2, yoffSet + (ypeak-yoffSet)/2, 'ro', 'linewidth', 3)

allignmentCenter = [round(xoffSet + (xpeak-xoffSet)/2,0),round(yoffSet + (ypeak-yoffSet)/2,0)];



%{
figure, imshow(inputImage)
hold on
plot(corner1(1), corner1(2), 'rx', 'linewidth', 3)
plot(corner2(1), corner2(2), 'rx', 'linewidth', 3)
plot(corner3(1), corner3(2), 'rx', 'linewidth', 3)
plot(corner4(1), corner4(2), 'rx', 'linewidth', 3)

%}
corners = zeros(4, 2);

corners(1, 1) = corner1(1);
corners(1, 2) = corner1(2);
corners(2, 1) = corner2(1);
corners(2, 2) = corner2(2);
corners(3, 1) = corner3(1);
corners(3, 2) = corner3(2);
corners(4, 1) = corner4(1);
corners(4, 2) = corner4(2);





