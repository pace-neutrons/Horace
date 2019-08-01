function w=IX_doubledisk_chopper(varargin)
% Constructor for IX_doubledisk_chopper object
%
%   >> doubledisk_chopper = IX_doubledisk_chopper (distance,frequency,radius,slot_width)
%
%   >> doubledisk_chopper = IX_doubledisk_chopper (...,aperture_width);
%   >> doubledisk_chopper = IX_doubledisk_chopper (...,aperture_width,aperture_height);
%   >> doubledisk_chopper = IX_doubledisk_chopper (...,aperture_width,aperture_height,jitter);
%
%   >> doubledisk_chopper = IX_doubledisk_chopper (name,...)
%
%   name            Name of the chopper (e.g. 'chopper_5')
%   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
%   frequency       Frequency of rotation of each disk (Hz)
%   radius          Radius of chopper body (m)
%   slot_width      Slit width (m)
%   aperture_width  Aperture width (m)
%   aperture_height Aperture height (m)
%   jitter          Timing uncertainty on chopper (FWHH) (microseconds)

% Original author: T.G.Perring

if nargin==0    % default constructor
    w.name = '';
    w.distance = 0;
    w.frequency = 0;
    w.radius = 0;
    w.slot_width = 0;
    w.aperture_width = 0;
    w.aperture_height = 0;
    w.jitter = 0;
    
elseif nargin==1 && isa(varargin{1},'IX_doubledisk_chopper')   % already is a double disk chopper
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
    if any(nargin-noff==[4,5,6,7])
        w.distance  = varargin{noff+1};
        w.frequency = varargin{noff+2};
        w.radius    = varargin{noff+3};
        w.slot_width= varargin{noff+4};
        if nargin-noff>=5
            w.aperture_width = varargin{noff+5};
        else
            w.aperture_width = w.slot_width;
        end
        if nargin-noff>=6
            w.aperture_height = varargin{noff+6};
        else
            w.aperture_height = 0;
        end
        if nargin-noff>=7
            w.jitter = varargin{noff+7};
        else
            w.jitter = 0;
        end
    else
        error('Check number of input arguments')
    end
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
end

w=class(w,'IX_doubledisk_chopper');
