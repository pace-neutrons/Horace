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
% $Revision$ ($Date$)
%
% Remove blanks from beginning and end of filename
filename=strtrim(filename);

% If no input parameter given, return
if ~exist('filename','var')
    help get_par;
    return
end

if H5F.is_hdf5(filename)
   error('LOAD_ASCII:load_ASCII_par',' file %s has to be an ascii file but it is hdf5 file\n',filename);
end


use_mex = get(herbert_config,'use_mex_C');
if use_mex
% Read par file
    try     %using C routine
        par=get_ascii_file(filename,'par');
    catch   %using matlab routine
        warning('HORACE:get_par','Can not invoke C++ procedure get_ascii_file.%s while loading from file: %s;\n Reason: %s',mexext(),filename,lasterr());    
        use_mex = false;
    end
end

if ~use_mex
    par=get_par_matlab(filename);
end



function par=get_par_matlab(filename)
% Load data from ASCII Tobyfit .par file using matlab

fid=fopen(filename,'rt');
if fid==-1,
   error('LOAD_ASCII_PAR:get_par_matlab','Error opening file %s\n',filename);
end

n=fscanf(fid,'%d \n',1);
disp(['Loading .par file with ' num2str(n) ' detectors : ' filename]);
temp=fgetl(fid);
par=sscanf(temp,'%f');
cols=length(par); % number of columns 5 or 6
par=[par;fscanf(fid,'%f')];
fclose(fid);
par=reshape(par,cols,n);


