function par=tofpar(varargin)
% Constructor for tofpar object
%
%   >> par = tofpar (emode, delta, ... , azimuth, efix)
%                                   % efix can be omitted if emode=0; efix will be set to 0
%
%   >> par = tofpar (par_struct)    % par_struct is a structure with fields emode, delta ... azimuth, efix
%
%   >> par = tofpar                 % will return an object of class tofpar, but with zero values for all fields
%
%
% Fields are:
%   emode   = 0,1 or 2 for elastic, direct geometry or indirect geometry
%   delta   = detector delay time (microseconds)
%   x1      = primary flight path (m)
%   x2      = secondary flight path (m)
%   twotheta= scattering angle (deg)
%   azimuth = azimuthal angle (deg)
%   efix    = fixed incident energy (meV)

% Original author: T.G.Perring

% Default class
if (nargin == 0)    % fill an empty object
    par.emode = 0;
    par.delta = 0;
    par.x1 = 1e-10;
    par.x2 = 0;
    par.twotheta = 0;
    par.azimuth = 0;
    par.efix = 0;
    [ok,mess,par]=checkfields(par);     % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, par=class(par,'tofpar'); return, else error(mess); end
    return
end

% Various input options
if nargin==1 && isa(varargin{1},'tofpar')   % if already tofpar object, return
    par=varargin{1};
    
elseif nargin==1 && isstruct(varargin{1})   % structure input
    [ok,mess,par]=checkfields(varargin{1}); % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, par=class(par,'tofpar'); return, else error(mess); end
    
elseif nargin==6 || nargin==7
    par.emode = varargin{1};
    par.delta = varargin{2};
    par.x1 = varargin{3};
    par.x2 = varargin{4};
    par.twotheta = varargin{5};
    par.azimuth = varargin{6};
    if nargin==7
        par.efix = varargin{7};
    else
        par.efix = [];  % to indicate value was not provided
    end
    [ok,mess,par]=checkfields(par);     % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, par=class(par,'tofpar'); return, else error(mess); end
    
else
    error('Check number of arguments')
end
