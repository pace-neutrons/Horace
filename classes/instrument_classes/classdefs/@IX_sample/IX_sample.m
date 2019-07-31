function w=IX_sample(varargin)
% Constructor for IX_sample object
%
%   >> sample = IX_sample (single_crystal)
%   >> sample = IX_sample (single_crystal,xgeom,ygeom)
%   >> sample = IX_sample (single_crystal,xgeom,ygeom,shape,ps)
%   >> sample = IX_sample (...,eta)
%   >> sample = IX_sample (...,eta,temperature)
%
%   >> sample = IX_sample (name,...)
%
%   name            Name of the sample (e.g. 'YBCO 6.6')
%   single_crystal  true if single crystal, false otherwise
%   xgeom           Direction of x-axis of geometric description (r.l.u)
%                  If not single crystal, can be empty array []
%   ygeom           Direction of y-axis of geometric description (r.l.u)
%                  If not single crystal, can be empty array []
%   shape           Model for pulse shape (e.g. 'cuboid')
%   ps              Parameters for the pulse shape model (array; length depends on pulse_model)
%   eta             Mosaic spread (FWHH) (deg)
%   temperature     Temperature of moderator (K)
    
% Original author: T.G.Perring

if nargin==0    % default constructor
    w.name = '';
    w.single_crystal = false;
    w.xgeom = [];
    w.ygeom = [];
    w.shape='';
    w.ps=[];
    w.eta=0;
    w.temperature = 0;
    
elseif nargin==1 && isa(varargin{1},'IX_sample')   % is a moderator object already
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
    if any(nargin-noff==[1,3,5,6,7])
        if nargin-noff>=1
            w.single_crystal = varargin{noff+1};
        else
            w.single_crystal = false;
        end
        if nargin-noff>=3
            w.xgeom = varargin{noff+2};
            w.ygeom = varargin{noff+3};
        else
            if w.single_crystal
                w.xgeom = [1,0,0];
                w.ygeom = [0,1,0];
            else
                w.xgeom = [];
                w.ygeom = [];
            end
        end
        if nargin-noff>=5
            w.shape = varargin{noff+4};
            w.ps = varargin{noff+5};
        else
            w.shape = '';
            w.ps = [];
        end
        if nargin-noff>=6
            w.eta = varargin{noff+6};
        else
            w.eta = 0;
        end
        if nargin-noff>=7
            w.temperature = varargin{noff+7};
        else
            w.temperature = 0;
        end
    else
        error('Check number of input arguments')
    end
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
end

w=class(w,'IX_sample');
