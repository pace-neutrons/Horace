function wout = phxObject (varargin)
% Create mslice phx data object
% 
%   >> w=phxObject(file)          % read from file
%   >> w=phxObject(structure)     % create from structure
%
% The fields of the phxObject class are:
%
%   phxObject.filename    Name of file excluding path
%   phxObject.filepath    Path to file including terminating file separator
%   phxObject.group       Row vector of detector group numbers (unique integers >=1)
%   phxObject.phi         Row vector of scattering angles (deg)
%   phxObject.azim        Row vector of azimuthal angles (deg)
%                       (West bank=0 deg, North bank=90 deg etc.)
%   phxObject.dphi        Row vector of angular widths (deg)
%   phxObject.danght      Row vector of angular heights (deg)
%
% The detector group numbers should be unique integers greater
% than or equal to one. However, for historical reasons a .phx file
% might have them all equal to a single value. In this case
% they will be set to 1,2,... ,ndet  where ndet is the total number of
% detetor groups in the file.

% Original author: T.G.Perring

classname='phxObject';

if nargin==1
    if isstruct(varargin{1})    % structure
        [ok,mess,wout]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
        if ok, wout = class(wout,classname); return, else error(mess); end
    elseif ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1
        if exist(varargin{1},'file') % file name
            [wout,ok,mess]=get_phxObject(varargin{1});
            if ~ok, error(mess); end
            [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
            if ok, wout = class(wout,classname); return, else error(mess); end
        else
            error('File does not exist')
        end
    else
        error('Check arguments')
    end
elseif nargin==0
    wout=default_phxObject;
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
else
    error('Check number of arguments')
end

%--------------------------------------------------------------------------------
function d=default_phxObject
% Make default phxObject structure, which is one with no detectors

%   phxObject.filename    Name of file excluding path
%   phxObject.filepath    Path to file including terminating file separator
%   phxObject.group       Row vector of detector group number - assumed to be 1:ndet
%   phxObject.phi         Row vector of scattering angles (deg)
%   phxObject.azim        Row vector of azimuthal angles (deg)
%                       (West bank=0 deg, North bank=90 deg etc.)
%   phxObject.dphi        Row vector of angular widths (deg)
%   phxObject.danght      Row vector of angular heights (deg)

d.filename='';
d.filepath='';
d.group=zeros(1,0);
d.phi=zeros(1,0);
d.azim=zeros(1,0);
d.dphi=zeros(1,0);
d.danght=zeros(1,0);
