function nb = matlab_nbits()
% function checks the number of bits in Matlab arcitecture
% 
%>>nb = matlab_nbits()
% returns the nuber of bits in current Matlab architecture (32 or 64)


ext = mexext();
arl = ext(4);
switch arl
    case 'w'
        %mexw32			32 bit MATLAB on Windows
        %mexw64			64 bit MATLAB on Windows
        if ext(5)=='6'
            nb = 64;
        elseif ext(5)=='3'
            nb = 32;
        else
            error('MATLAB:NBITS',' unknown windows architecture with extension %s (not 32 or 64 bit architecture)',ext)
        end
    case 'g'
        %mexglx			32 bit MATLAB on Linux        
        nb = 32;
    case 'a'
        %mexa64			64 bit MATLAB on Linux
        nb= 64;
    case 'm'
        %    mexmac		32 bit MATLAB on Mac
        %    mexmaci	32 bit MATLAB on Intel-based Mac
        %    mexmaci64	64 bit MATLAB on Intel-based Mac
        if numel(ext) == 5
            nb = 32;            
        elseif numel(ext) == 6
            nb = 32;            
        elseif numel(ext) == 8
            nb = 64;
        else
            error('MATLAB:NBITS',' unknown max architecture with extension %s (not 32 or 64 bit architecture)',ext)            
        end
    otherwise        
       error('MATLAB:NBITS',' unknown architecture with extension %s ',ext)
end
