function strout = tnm034(im) 
% 
% Im should be in double format, normalized to the interval [0,1] 
% strout: The resulting character string of the coded 
% The string must have exactly the number of characters that 
% corresponds to the information in the code. 


%First step: Find the corner points, call the corresponding function
%qrImage = findQR(im);

strout = decodeQR(im);

%string = 'tjena'; 
%strout=char(string);