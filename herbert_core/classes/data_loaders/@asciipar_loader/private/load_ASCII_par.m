function par=load_ASCII_par(filename)
% Load data from ASCII Tobyfit .par file
%   >> par = load_ASCII_par(filename)
%
% data has following fields:
%
%     par(6,ndet)   contents of array
%
%     1st column    sample-detector distance
%     2nd  "        scattering angle (deg)
%     3rd  "        azimuthal angle (deg)
%                   (west bank = 0 deg, north bank = -90 deg etc.)
%                   (Note the reversed sign convention cf .phx files)
%     4th  "        width (m)
%     5th  "        height (m)
%     6th  "        detector ID

%  if varargin present, do not convert into detector structure but return
%  initial array

% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)

% If no input parameter given, return
if ~exist('filename','var')
    help load_ASCII_par;
    return
end
% Remove blanks from beginning and end of filename
filename=strtrim(filename);

% Move to if_loader_correct
% if H5F.is_hdf5(filename)>0
%     error('LOAD_ASCII:load_ASCII_par',' file %s has to be an ascii file but it is hdf5 file\n',filename);
% end

use_mex = get(herbert_config,'use_mex_C');
if use_mex
    try     %using C routine
        par=get_ascii_file(filename,'par');
    catch   %using matlab routine
        force_mex = get(herbert_config,'force_mex_if_use_mex');
        if ~force_mex
            warning('ASCIIPAR_LOADER:load_par','Cannot invoke C++ procedure get_ascii_file.%s while loading from file: %s;\n Reason: %s',mexext(),filename,lasterr());
            use_mex = false;
        else
            error('ASCIIPAR_LOADER:load_par','Cannot invoke C++ procedure get_ascii_file.%s while loading from file: %s;\n Reason: %s',mexext(),filename,lasterr());
        end
    end
end

if ~use_mex
    par=get_par_matlab(filename);
end

par(3,:) = -par(3,:);




function par=get_par_matlab(filename)
% Load data from ASCII Tobyfit .par file using matlab

fid=fopen(filename,'rt');
if fid==-1,
    error('A_LOADER:get_par_matlab','Error opening file %s\n',filename);
end

n=fscanf(fid,'%d \n',1);
if get(herbert_config,'log_level')>0
    disp(['Loading .par file with ' num2str(n) ' detectors : ' filename]);
end
temp=fgetl(fid);
par=sscanf(temp,'%f');
cols=length(par); % number of columns 5 or 6
par=[par;fscanf(fid,'%f')];
fclose(fid);
par=reshape(par,cols,n);

