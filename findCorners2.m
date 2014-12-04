function [cornerPoint] = findCorners2(inputCorner, cornerNr)

width = size(inputCorner, 2);
height = size(inputCorner, 1);
%thresh = graythresh(inputCorner);
%inBinary = binarize(inputCorner);
check = false;
inBinary = inputCorner;
%inBinary = bwmorph(inBinary, 'thicken');
returnCorner = zeros(1,2);

% figure, imshow(inBinary)
% hold on 
% plot(width/2, height/2, 'co', 'linewidth', 2)

switch(cornerNr)
    case 1
       %Corner one: Left, Up
        for i = 1:height
           for j = 1:width
               if sum(inBinary(i, j:width)) == 0 && sum(inBinary(i:height, j)) == 0
                  returnCorner(1,1) = i;
                  returnCorner(1,2) = j;
%                   figure, imshow(inBinary)
%                   hold on
%                   plot(returnCorner(2), returnCorner(1), 'rx')
                  check = true;
                  break;
               else
                i = i+1;
               end
           end
           if check 
              break;           
           end
        end
    case 2
        %Corner2: Up, Right
        for i = 1:height
           for j = width:-1:1
               if sum(inBinary(i, 1:j)) == 0 && sum(inBinary(i:height, j)) == 0
                  returnCorner(1,1) = i;
                  returnCorner(1,2) = j;
%                   figure, imshow(inBinary)
%                   hold on
%                   plot(returnCorner(2), returnCorner(1), 'rx')
                  check = true;
                  break;
               else
                   i = i+1;
               end
           end
           if check 
              break; 
           end
        end
         
    case 3
        %Corner3: Down, Left
        for i = height:-1:1
           for j = 1:width
               if sum(inBinary(1:i, j)) == 0 && sum(inBinary(i, j:width)) == 0
                  returnCorner(1,1) = i;
                  returnCorner(1,2) = j;
%                   figure, imshow(inBinary)
%                   hold on
%                   plot(returnCorner(2), returnCorner(1), 'rx')
                  check = true;
                  break;
               else
                   i = i-1;
               end
           end
           if check 
              break; 
           end
        end      
end

cornerPoint = returnCorner;

