function this=load_par(this,varargin)
% Load data from ASCII Tobyfit .par file
% >> this = detectors.load_par();
% >> this = detectors.load_par(filename);
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
%  filename    --- if present, it redefines early defined filename
%  
%
%  if varargin present, do not convert into detector structure but return
%  initial array 

% Original author: T.G.Perring
%
% $Revision: 531 $ ($Date: 2011-02-18 22:10:44 +0000 (Fri, 18 Feb 2011) $)
%
filename = fullfile(this.filepath,this.filename);
if ~exist(filename,'file')
    error('DETECTORS_PAR:load_par',' detectors par file %s does not exist',filename);
end
% redefine
if nargin>1
    if ischar(varargin{1})
        new_file = varargin{1};
        if ~exist(new_file,'file')
            error('DETECTORS_PAR:load_par',' new detectors file %s requested by load_par does not exist',new_file);
        end
        
        [this.filepath,filename,ext]=fileparts(filename);
        this.filename=[filename,ext];
    end
end

use_mex = get(hor_config,'use_mex');
if use_mex
% Read par file
    try     %using C routine
        par=get_ascii_file(filename,'par');
    catch   Err%using matlab routine
        warning('DETECTORS_PAR:load_par','Can not invoke C procedure get_ascii_file.mexXXX loading from file: %s;\n Reason: %s',filename,Err.message);    
        use_mex = false;
    end
end

if ~use_mex
    par=get_par_matlab(filename);
end

if nargin==1
     ndet=size(par,2);
     disp([num2str(ndet) ' detector(s)']);
     this.group=1:ndet;
     this.x2=par(1,:);
     this.phi=par(2,:);
     this.azim=-par(3,:); % Note sign change to get correct convention
     this.width=par(4,:);
     this.height=par(5,:);
end
