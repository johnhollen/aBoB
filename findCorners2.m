function [cornerPoint] = findCorners2(inputCorner, cornerNr)

width = size(inputCorner, 2);
height = size(inputCorner, 1);

inBinary = inputCorner;
returnCorner = zeros(1,2);

switch(cornerNr)
    case 1
        i = height;
        j = width;
        while i > 1 && j > 1
           if inBinary(i,j) == 0 && inBinary(i-1, j-1) == 1
              returnCorner(1,1) = i;
              returnCorner(1,2) = j;
              break;
           end
           i = i-1;
           j = j-1;
        end
    case 2
        %Corner2: Up, Right
        i = height;
        j = 1;
        while i > 1 && j < width
           if inBinary(i,j) == 0 && inBinary(i-1, j+1) == 1
              returnCorner(1,1) = i;
              returnCorner(1,2) = j;
              break;
           end
           i = i-1;
           j = j+1;
        end         
    case 3
        %Corner3: Down, Left
        i = 1;
        j = width;
        while i < height && j > 1
           if inBinary(i,j) == 0 && inBinary(i+1, j-1) == 1
              returnCorner(1,1) = i;
              returnCorner(1,2) = j;
              break;
           end
           i = i+1;
           j = j-1;
        end   
end

cornerPoint = returnCorner;

