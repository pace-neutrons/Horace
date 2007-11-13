function par=get_par_matlab(filename)
% Load data from ASCII Tobyfit .par file
%   >> par = get_par(filename)
%
%     filename      name of par file
%
%     par(5,ndet)   contents of array
%
%     1st column    sample-detector distance
%     2nd  "        scattering angle (deg)
%     3rd  "        azimuthal angle (deg)
%                   (west bank = 0 deg, north bank = -90 deg etc.)
%                   (Note the reversed sign convention cf .phx files)
%     4th  "        width (m)
%     5th  "        height (m)
%
% T.G.Perring   13/6/07
% I. Bustinduy  17/08/08

% If no input parameter given, return
if ~exist('filename','var')
    help get_par;
    return
end
        
% Remove blanks from beginning and end of filename
filename=strtrim(filename); 
% === load detector information in .par format
fid=fopen(filename,'rt');
n=fscanf(fid,'%5d \n',1);
%disp(['Loading .par file with ' num2str(n) ' detectors: ' filename]);
temp=fgetl(fid);
par=sscanf(temp,'%f');
cols=length(par); % number of columns 5 or 6
par=[par;fscanf(fid,'%f')];
fclose(fid);
par=reshape(par,cols,n);
%disp(['Matlab loading of .par file : ' filename]);
                                            
