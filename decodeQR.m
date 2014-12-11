function [qrCode] = decodeQR(image)
%Function for finding and extracting the QR-code

% Calculate stepsize in the image between every bit in the QR-code
dim = size(image)/41;

% Stegl?ngd i x o y-led
stepX = dim(1);
stepY = dim(2);
  
%Temporary variables for taking 8 bits at a time as well as convert to char
tempString = zeros(1,8);
totString = '';
% Iterate 41x41 times over the Qr-code
count=0;
for j=1:41
    for i=1:41
        % Skip fiducial mark in x direction
        if j<9   
            
            if i<9 || i>33 
               % No nothing on fiducial mark  
            else
                % Check CODE! 
                if count ~= 8
                    count=count+1;
                    tempString(count)= image(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                       
                else
                    number = bi2de(tempString,'left-msb');
                    count=0;
                   
                    s1 = char(number);
                    totString = [totString s1];
                    
                    % Add the first dot
                    count=count+1;
                    tempString(count)= image(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    
                end
            end
        elseif i>32 && j>32 && i<38 && j<38
            % Alignment pattern ==> no nothing..         
        elseif j>33
            if i<9  
                %Do nothing on fiducial mark
            else
                % Check CODE!
                if count ~= 8
                    count=count+1;
                    tempString(count)= image(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                                        
                else
                    number = bi2de(tempString,'left-msb');
                    count=0;
         
                    s1 = char(number);
                    totString = [totString s1];
                    
                    % Add the first dot
                    count=count+1;
                    tempString(count)= image(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    
                end
            end       
        else
            % Check CODE!
            if count ~= 8
                    count=count+1;
                    tempString(count)= image(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                                     
            else
                    number = bi2de(tempString,'left-msb');
                    count=0;
                    
                    s1 = char(number);
                    totString = [totString s1];                   
                  
                     % Add the first dot
                    count=count+1;
                    tempString(count)= image(round((i-1)*stepX+stepX/2),round((j-1)*stepY+stepY/2));
                    
           end  
        end     
    end
end

qrCode = totString;