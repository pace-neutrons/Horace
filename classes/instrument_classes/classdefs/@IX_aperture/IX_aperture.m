function w=IX_sample(varargin)
% Constructor for IX_aperture object
%
%   >> aperture = IX_aperture (width,height)
%   >> aperture = IX_aperture (name,width,height)
%
%   name            Name of the aperture (e.g. 'in-pile')
%   width           Width of aperture (m)
%   height          Height of aperture (m)
    
% Original author: T.G.Perring

if nargin==0    % default constructor
    w.name = '';
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
    if isstring(varargin{1})
        w.name = varargin{1};
        noff=1;
    else
        w.name = '';
        noff=0;
    end
    if any(nargin-noff==[2])
        if nargin-noff>=2
            w.width = varargin{noff+1};
            w.height= varargin{noff+2};
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
