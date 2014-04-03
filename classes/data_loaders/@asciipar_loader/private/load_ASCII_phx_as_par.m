function par=load_ASCII_phx_as_par(filename)
% Load data from ASCII mslice .phx file
%   >> par = load_ASCII_phx_as_par(filename)
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

% Remove blanks from beginning and end of filename


% If no input parameter given, return
if ~exist('filename','var')
    help get_par;
    return
end

filename=strtrim(filename);

use_mex = get(herbert_config,'use_mex_C');
if use_mex
    try     %using C routine
        phx=get_ascii_file(filename,'phx');
    catch   %using matlab routine
        force_mex = get(herbert_config,'force_mex_if_use_mex');
        if ~force_mex
            warning('A_LOADER:get_phx','Cannot invoke C++ procedure get_ascii_file.%s while loading from file: %s;\n Reason: %s',mexext(),filename,lasterr());
            use_mex = false;
        else
            error('A_LOADER:get_phx','Cannot invoke C++ procedure get_ascii_file.%s while loading from file: %s;\n Reason: %s',mexext(),filename,lasterr());
        end
    end
end

if ~use_mex
   phx=get_phx_matlab(filename);
end
% convert phx to par (not implemented)
par = phx;



function phx= get_phx_matlab(file_tmp)
% Read file (use matlab)

% Open file for reading
fid=fopen(file_tmp,'rt');
if fid==-1
    error('A_LOADER:io_error','Error opening phx file %s',file_tmp);
end

% Get number of detectors
ndet=fscanf(fid,'%d\n',1);
if get(herbert_config,'log_level')>0
    disp(['Loading .phx file with ' num2str(ndet) ' detectors : ' file_tmp]);
end
if ndet<0
    fclose(fid);
    error('A_LOADER:io_error','Error opening phx file %s',file_tmp);
end
% Read the the phx file
phx=fscanf(fid,'%f');
fclose(fid);
if numel(phx)~=ndet*7
    error('A_LOADER:io_error',['File determined to have ',num2str(ndet),' detectors, but contents are inconsistent with a .phx file']);
end
phx = reshape(phx,7,ndet);
% exclude 2-nd row to have the same format as  par
phx=[phx(1,:);phx(3:7,:)];

group=unique(round(phx(6,:)));
if numel(group)==1      % all group numbers were the same (when rounded to the nearest integer)
    phx(6,:) =1:ndet;
elseif ~(numel(group)==ndet && min(group)>0)
    error('A_LOADER:io_error','The detector group numbers must be unique integers >= 1, or all the same (when they will be set to 1:ndet');
end
%     phx.group=group;
%     phx.phi=arr(3,:);
%     phx.azim=arr(4,:);
%     phx.dphi=arr(5,:);
%     phx.danght=arr(6,:);
    
