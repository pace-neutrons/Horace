function w=IX_fermi_chopper(varargin)
% Constructor for IX_fermi_chopper object
%
%   >> fermi_chopper = IX_fermi_chopper (distance,frequency,radius,curvature,slit_width)
%
%   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing)
%
%   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy);
%
%   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase);
%
%   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase,ntable);
%
%   >> fermi_chopper = IX_fermi_chopper (name,...)
%
%   name            Name of the slit package (e.g. 'sloppy')
%   distance        Distance from sample (m) (+ve if upstream of sample)
%   frequency       Frequency of rotation (Hz)
%   radius          Radius of chopper body (m)
%   curvature       Radius of curvature of slits (m)
%   slit_width      Slit width (m)  (Fermi)
%   slit_spacing    Spacing between slit centres (m)
%   width           Width of aperture (m)
%   height          Height of aperture (m)
%   energy          Energy of neutrons transmitted by chopper (mev) 
%   phase           Phase = true if correctly phased, =false if 180 degree rotated
%   ntable          Number of points in sampling table for Monte Carlo (ntable>=2)

% Original author: T.G.Perring

npnt_default=50;
if nargin==0    % default constructor
    w.name = '';
    w.distance = 0;
    w.frequency = 0;
    w.radius = 0;
    w.curvature = 0;
    w.slit_width = 0;
    w.slit_spacing = 0;
    w.width = 0;
    w.height = 0;
    w.energy= 0;
    w.phase = true;
    w.ntable = npnt_default;
    w.table=[];
    
elseif nargin==1 && isa(varargin{1},'IX_fermi_chopper')   % is a fermi chopper object already
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
    if any(nargin-noff==[5,6,8,9,10,11])
        w.distance  = varargin{noff+1};
        w.frequency = varargin{noff+2};
        w.radius    = varargin{noff+3};
        w.curvature = varargin{noff+4};
        w.slit_width= varargin{noff+5};
        if nargin-noff>=6
            w.slit_spacing = varargin{noff+6};
        else
            w.slit_spacing = w.slit_width;
        end
        if nargin-noff>=8
            w.width = varargin{noff+7};
            w.height= varargin{noff+8};
        else
            w.width = 0;
            w.height= 0;
        end
        if nargin-noff>=9
            w.energy = varargin{noff+9};
        else
            w.energy = 0;
        end
        if nargin-noff>=10
            w.phase = varargin{noff+10};
        else
            w.phase = true;
        end
        if nargin-noff>=11
            w.ntable = varargin{noff+11};
            w.table = [];
        else
            w.ntable = npnt_default;
            w.table = [];
        end
    else
        error('Check number of input arguments')
    end
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
end

w=class(w,'IX_fermi_chopper');
