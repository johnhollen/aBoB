function [qrCode] = decodeQR(image)
%Function for finding and extracting the QR-code
% Input= Image(2d/3d) CHANGE TO BINARY IMAGE LATER!!
% Output= Decoded string of the QR image..


binary = image;
% Ber?kna stegl?ngd i bilden mellan varje bit av QR-kod
dim = size(binary)/41;

% Stegl?ngd i x o y-led
stepX = dim(1);
stepY = dim(2);
  

% Tempor?ra variabler f?r att ta 8 bitar i taget samt skapa en str?ng av de
% ?versatta bitarna
tempString = zeros(1,8);
totString = '';
% Iterate 41x41 ggr ?ver hela QR koden..
count=0;
for j=1:41
    for i=1:41
        % Hoppa ?ver FIP i x-led
        if j<9   
            
            if i<9 || i>33 
               % No nothing on FIP!   
            else
                % Check CODE! 
                if count ~= 8
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                       
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
                    
                end
            end       
        else
            % Check CODE!
            if count ~= 8
                    count=count+1;
                    tempString(count)= binary(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                                     
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
                    
           end  
        end     
    end
end

qrCode = totString;