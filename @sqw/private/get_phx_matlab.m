function phx=get_phx_matlab(filename)
% Matlab loading of phx file
% Syntax:
%   >> phx = get_phx_matlab (filename)
%
%   filename            name of phx file
%
%   phx(7,ndet)         contents of array
%
% Recall that only the 3,4,5,6 columns in the file (rows in the
% output of this routine) contain useful information
%   3rd column      scattering angle (deg)
%   4th  "			azimuthal angle (deg)
%   (west bank = 0 deg, north bank = 90 deg etc.)
%   5th  "			angular width (deg)
%   6th  "			angular height (deg)

% Original author: Ibon Bustinduy
%
% $Revision$ ($Date$)
%
% Toby Perring

filename=strtrim(filename); % Remove blanks from beginning and end of filename
if isempty(filename),
   error('Filename is empty')
end
fid=fopen(filename,'rt');
if fid==-1,
   error(['Error opening file ',filename]);
end

phx=fscanf(fid,'%f');
fclose(fid);
disp(['Loading .phx file with ' num2str(phx(1)) ' detectors : ' filename]);
phx=reshape(phx(2:end),7,phx(1));
