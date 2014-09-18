classdef IX_fermi_chopper
    % Constructor for IX_fermi_chopper object
    %
    %   >> fermi_chopper = IX_fermi_chopper (distance,frequency,radius,curvature,slit_width)
    %
    %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing)
    %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy);
    %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase);
    %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase,jitter);
    %
    %   >> fermi_chopper = IX_fermi_chopper (name,...)
    %
    % Original author: T.G.Perring
    properties
        name='';            %Name of the slit package (e.g. 'sloppy')
        distance=0;        %Distance from sample (m) (+ve if upstream of sample, against the usual convention)
        frequency=0;       %Frequency of rotation (Hz)
        radius=0;          %Radius of chopper body (m)
        curvature=0;       %Radius of curvature of slits (m)
        slit_width=0;      %Slit width (m)  (Fermi)
        slit_spacing=0;    %Spacing between slit centres (m)
        width=0 ;          %Width of aperture (m)
        height=0;          %Height of aperture (m)
        energy=0;          %Energy of neutrons transmitted by chopper (mev)
        phase=true;        %Phase = true if correctly phased, =false if 180 degree rotated
        jitter=0;          %Timing uncertainty on chopper (FWHH) (microseconds)
        
    end
    
    methods
        function w=IX_fermi_chopper(varargin)
            
            if nargin==0    % default constructor
                return
               
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
                        w.jitter = varargin{noff+11};
                    else
                        w.jitter = 0;
                    end
                else
                    error('Check number of input arguments')
                end
                [ok,mess,w]=checkfields(w);
                if ~ok, error(mess), return, end
                
            end
            
            
        end
    end
end