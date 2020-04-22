function wout = parObject (varargin)
% Create Horace/Tobyfit par data object
% 
%   >> w=parObject(file)          % read from file
%   >> w=parObject(structure)     % create from structure
%
% The fields of the parObject class are:
%
%   parObject.filename    Name of file excluding path
%   parObject.filepath    Path to file including terminating file separator
%   parObject.group       Row vector of detector group numbers (unique integers >=1)
%   parObject.x2          Secondary flightpath (m) (must be all greater than zero)
%   parObject.phi         Row vector of scattering angles (deg)
%   parObject.azim        Row vector of azimuthal angles (deg)
%                       (West bank=0 deg, North bank=90 deg etc.)
%   parObject.width       Row vector of detector widths (m) (all >=0)
%   parObject.height      Row vector of detector heights (m) (all >=0)
%
% Note that the azimuthal angle follows the usual convention of 
% anticlockwise rotation is positive. The ascii .par file stores it
% with the opposite convention. The sign is changed when the file is
% read using methods of this class.
%
% The detector group numbers should be unique integers greater
% than or equal to one. However, for historical reasons a .par file
% might contain no detector group numbers, or have them all equal to 
% a single value (little attention was paid to them). In these two cases
% they will be set to 1,2,... ,ndet  where ndet is the total number of
% detetor groups in the file.

% Original author: T.G.Perring

classname='parObject';

if nargin==1
    if isstruct(varargin{1})    % structure
        [ok,mess,wout]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
        if ok, wout = class(wout,classname); return, else error(mess); end
    elseif ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1
        if exist(varargin{1},'file') % file name
            [wout,ok,mess]=get_parObject(varargin{1});
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
    wout=default_parObject;
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
else
    error('Check number of arguments')
end

%--------------------------------------------------------------------------------
function d=default_parObject
% Make default parObject structure, which is one with no detectors

%   parObject.filename    Name of file excluding path
%   parObject.filepath    Path to file including terminating file separator
%   parObject.group       Row vector of detector group number - assumed to be 1:ndet
%   parObject.x2          Secondary flightpath (m)
%   parObject.phi         Row vector of scattering angles (deg)
%   parObject.azim        Row vector of azimuthal angles (deg)
%                       (West bank=0 deg, North bank=90 deg etc.)
%   parObject.width       Row vector of detector widths (m)
%   parObject.height      Row vector of detector heights (m)

d.filename='';
d.filepath='';
d.group=zeros(1,0);
d.x2=zeros(1,0);
d.phi=zeros(1,0);
d.azim=zeros(1,0);
d.width=zeros(1,0);
d.height=zeros(1,0);
