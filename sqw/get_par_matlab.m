function par=get_par_matlab(filename)
% Load data from ASCII Tobyfit .par file
%   >> par = get_par_matlab(filename)
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

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)
%
% Ibon Bustinduy

filename=strtrim(filename); % Remove blanks from beginning and end of filename
if isempty(filename),
   error('Filename is empty')
end
fid=fopen(filename,'rt');
if fid==-1,
   error(['Error opening file ',filename]);
end

n=fscanf(fid,'%d \n',1);
disp(['Loading .par file with ' num2str(n) ' detectors : ' filename]);
temp=fgetl(fid);
par=sscanf(temp,'%f');
cols=length(par); % number of columns 5 or 6
par=[par;fscanf(fid,'%f')];
fclose(fid);
par=reshape(par,cols,n);
