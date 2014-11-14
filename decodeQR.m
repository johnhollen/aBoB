function [qrCode] = decodeQR(image)
%Function for finding and extracting the QR-code
% Input= Image(2d/3d) CHANGE TO BINARY IMAGE LATER!!
% Output= Decoded string of the QR image..

image = im2double(image);
%Check dimension and normalize image
imageDim = size(image, 3);
disp(sprintf('Dimension of image is %d', imageDim))

greyScale = im2double(image);

%Create greyscale image if the image is in color
if imageDim == 3
   greyScale = (greyScale(:,:,1)+greyScale(:,:,2)+greyScale(:,:,3))/3;
end
binary = binarize(greyScale);

imshow(binary);
hold on

% Beräkna steglängd i bilden mellan varje bit av QR-kod
dim = size(binary)/41;

% Steglängd i x o y-led
stepX = dim(1);
stepY = dim(2);
  

% Temporära variabler för att ta 8 bitar i taget samt skapa en sträng av de
% översatta bitarna
tempString = zeros(1,8);
totString = '';
% Iterate 41x41 ggr över hela QR koden..
count=0;
for j=1:41
    for i=1:41
        % Hoppa över FIP i x-led
        if j<9   
            
            if i<9 || i>33 
               % No nothing on FIP!   
            else
                % Check CODE! 
                if count ~= 8
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    %plot(round((j-1)*stepY+stepY/2),round((i-1)*stepX+stepX/2), 'ro', 'linewidth', 1);   
                else
                    number = bi2de(tempString,'left-msb');
                    count=0;
                    if(number > 31 && number < 400)
                        s1 = char(number);
                        totString = [totString s1];
                    end
                    % Add the first dot
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    %plot(round((j-1)*stepY+stepY/2),round((i-1)*stepX+stepX/2), 'ro', 'linewidth', 1);
                end
            end
        elseif i>32 && j>32 && i<38 && j<38
            % Alignment pattern ==> no nothing..         
        elseif j>33
            if i<9  
                %Do nothing on FIP!
            else
                % Check CODE!
                if count ~= 8
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    %plot(round((j-1)*stepY+stepY/2),round((i-1)*stepX+stepX/2), 'ro', 'linewidth', 1);
                    
                else
                    number = bi2de(tempString,'left-msb');
                    count=0;
                    if(number > 31 && number < 400)
                        s1 = char(number);
                        totString = [totString s1];%strcat(totString,s1);
                    end
                    % Add the first dot
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    %plot(round((j-1)*stepY+stepY/2),round((i-1)*stepX+stepX/2), 'ro', 'linewidth', 1);
                end
            end       
        else
            % Check CODE!
            if count ~= 8
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    %plot(round((j-1)*stepY+stepY/2),round((i-1)*stepX+stepX/2), 'ro', 'linewidth', 1);                 
            else
                    number = bi2de(tempString,'left-msb');
                    count=0;
                    if(number > 31 && number < 400)
                        s1 = char(number);
                        totString = [totString s1];
                    end
                  
                     % Add the first dot
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    %plot(round((j-1)*stepY+stepY/2),round((i-1)*stepX+stepX/2), 'ro', 'linewidth', 1);
           end  
        end     
    end
end

qrCode = totString;