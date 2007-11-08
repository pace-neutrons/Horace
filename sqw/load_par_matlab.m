function det=load_par_matlab(filename)
% Load data from ASCII Tobyfit .par file
%   >> det = load_par(filename)
%
% data has following fields:
%   det.filename    Name of file excluding path
%   det.filepath    Path to file including terminating file separator
%   det.x2          Secondary flightpath (m)
%   det.group       Row vector of detector group number - assumed to be 1:ndet
%   det.phi         Row vector of scattering angles (deg)
%   det.azim        Row vector of azimuthal angles (deg)
%                  (West bank=0 deg, North bank=90 deg etc.)
%   det.width       Row vector of detector widths (m)
%   det.height      Row vector of detector heights (m)

% T.G.Perring   13/6/07
% I. Bustinduy  17/08/08

% If no input parameter given, return
if ~exist('filename','var')
    help load_par;
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
                                            
