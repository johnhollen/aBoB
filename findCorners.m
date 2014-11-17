function [corners] = findCorners(inputImage)
%FINDCORNERS Function for finding corners in cropped Qrcode image

corner1 = zeros(1, 2);
corner2 = zeros(1, 2);
corner3 = zeros(1, 2);
corner4 = zeros(1, 2);
check = false;


dimz= length(inputImage);

%Corner one: Left, Up
for i=1:dimz
    if(inputImage(i, i) == 0)
        k = i-1;
        corner1 = [i, i];
        while inputImage(k, i) == 0
            corner1 = [i, k];
            k = k-1;
        end
        k = i-1;
        while inputImage(i, k) == 0
            corner1(1) = k;
            k = k-1;
        end
        check = true;
    end
    if check 
        break;
    end
end
check = false;
%Corner2: Left, Down
rowIndex = 1;
for i=dimz:-1:1
    if(inputImage(i, rowIndex) == 0)
        k = rowIndex-1;
        corner2 = [rowIndex, i];
        while inputImage(rowIndex, k) == 0
            corner2 = [k, i];
            k = k-1;
        end
        k = i-1;
        while inputImage(k, rowIndex) == 0
            corner2(2) = k;
            k = k+1;
        end
       check = true;
    end
    if check 
        break;
    end
    rowIndex = rowIndex+1;
end

check = false;
%Corner3: Up, Right
rowIndex = dimz;
for i=1:dimz
    if(inputImage(i, rowIndex) == 0)
       corner3 = [rowIndex, i];
       k = i + 1;
       while inputImage(k, rowIndex) == 0
          corner3 = [rowIndex, k];
          k = k-1;
       end
       k = rowIndex+1;
       while inputImage(rowIndex, k) == 0
          corner3(1) = k;
          k = k+1;
       end
       check = true;
    end
    if check 
        break;
    end
    rowIndex = rowIndex-1;
end
check = false;
%Corner4: Down, Right
for i=dimz:-1:1
    if(inputImage(i, i) == 0)
       corner4 = [i, i];
       k = i-1;
       while inputImage(i, k) == 0
          corner4 = [k, i];
          k = k+1;
       end
       k = i-1;
       while inputImage(k, i) == 0
          corner(2) = k;
          k = k+1;
       end
       check = true;
    end
    if check 
        break;
    end
end

corners = zeros(4, 2);

corners(1, 1) = corner1(1);
corners(1, 2) = corner1(2);
corners(2, 1) = corner2(1);
corners(2, 2) = corner2(2);
corners(3, 1) = corner3(1);
corners(3, 2) = corner3(2);
corners(4, 1) = corner4(1);
corners(4, 2) = corner4(2);






