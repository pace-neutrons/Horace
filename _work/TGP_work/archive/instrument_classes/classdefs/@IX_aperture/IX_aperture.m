function w=IX_aperture(varargin)
% Constructor for IX_aperture object
%
%   >> aperture = IX_aperture (distnce,width,height)
%   >> aperture = IX_aperture (name,distance,width,height)
%
%   name            Name of the aperture (e.g. 'in-pile')
%   distance        Distance from sample (-ve if upstream, +ve if downstream)
%   width           Width of aperture (m)
%   height          Height of aperture (m)
    
% Original author: T.G.Perring

if nargin==0    % default constructor
    w.name = '';
    w.distance = 0;
    w.width = 0;
    w.height = 0;
    
elseif nargin==1 && isa(varargin{1},'IX_aperture')   % is a moderator object already
    w = varargin{1};
    return
    
elseif nargin==1 && isstruct(varargin{1})    % structure
    w = varargin{1};
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
else
    if is_string(varargin{1})
        w.name = varargin{1};
        noff=1;
    else
        w.name = '';
        noff=0;
    end
    if any(nargin-noff==[1,3])
        w.distance=varargin{noff+1};
        if nargin-noff==3
            w.width = varargin{noff+2};
            w.height= varargin{noff+3};
        else
            w.width = 0;
            w.height= 0;
        end
    else
        error('Check number of input arguments')
    end
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
end

w=class(w,'IX_aperture');
