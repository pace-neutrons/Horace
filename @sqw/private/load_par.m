function det=load_par(this,filename,varargin)
% Load data from ASCII Tobyfit .par file
%   >> det = get_par(filename)
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
%
%  if varargin present, do not convert into detector structure but return
%  initial array 

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%

% Remove blanks from beginning and end of filename
filename=strtrim(filename);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(filename);
det.filename=[name,ext];
det.filepath=[path,filesep];

use_mex = get(hor_config,'use_mex');
if use_mex
% Read par file
    try     %using C routine
        par=get_ascii_file(filename,'par');
    catch   %using matlab routine
        warning('HORACE:get_par','Can not invoke C procedure get_ascii_file.%s while loading from file: %s;\n Reason: %s',mexext(),filename,lasterr());    
        use_mex = false;
    end
end

if ~use_mex
    par=get_par_matlab(filename);
end

ndet=size(par,2);  
if nargin==2
    if get(hor_config,'horace_info_level')>0
        disp([num2str(ndet) ' detector(s)']);
    end
    det.group=1:ndet;
    det.x2=par(1,:);
    det.phi=par(2,:);
    det.azim=-par(3,:); % Note sign change to get correct convention
    det.width=par(4,:);
    det.height=par(5,:);
else
    if size(par,1)==5              
        det = ones(6,ndet);        
        det(1:5,:)=par(1:5,:);
        det(6,:)=1:ndet;
    else
        det=par;  
    end
end
