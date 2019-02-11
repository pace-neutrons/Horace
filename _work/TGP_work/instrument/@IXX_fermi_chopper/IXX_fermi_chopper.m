classdef IXX_fermi_chopper
    % Fermi chopper class definition
    properties (Constant, Access=private)
        % Conversion constant. Should replace by a class that gives constants
        c_e_to_t_ = 2.286271439537201e+03;
    end
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties        
        name_ = '';
        distance_ = 0;
        frequency_ = 0;
        radius_ = 0;
        curvature_ = 0;
        slit_width_ = 0;
        slit_spacing_ = 0;
        width_ = 0;
        height_ = 0;
        energy_ = 0;
        phase_ = true;
        jitter_ = 0;
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        distance
        frequency
        radius
        curvature
        slit_width
        slit_spacing
        width
        height
        energy
        phase
        jitter
    end
    
    properties (Access=private)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IXX_fermi_chopper (varargin)
            % Create fermi chopper object
            %   >> fermi_chopper = IX_fermi_chopper (distance,frequency,radius,curvature,slit_width)
            %
            %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing)
            %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy);
            %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase);
            %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase,jitter);
            %
            %   >> fermi_chopper = IX_fermi_chopper (name,...)
            %
            %   name            Name of the slit package (e.g. 'sloppy')
            %   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
            %   frequency       Frequency of rotation (Hz)
            %   radius          Radius of chopper body (m)
            %   curvature       Radius of curvature of slits (m)
            %   slit_width      Slit width (m)  (Fermi)
            %   slit_spacing    Spacing between slit centres (m)
            %   width           Width of aperture (m)
            %   height          Height of aperture (m)
            %   energy          Energy of neutrons transmitted by chopper (mev)
            %   phase           Phase = true if correctly phased, =false if 180 degree rotated
            %   jitter          Timing uncertainty on chopper (FWHH) (microseconds)
            
            
            if nargin>=1
                if is_string(varargin{1})
                    obj.name = varargin{1};
                    noff=1;
                else
                    obj.name = '';
                    noff=0;
                end
                if any(nargin-noff==[5,6,8,9,10,11])
                    obj.distance  = varargin{noff+1};
                    obj.frequency = varargin{noff+2};
                    obj.radius    = varargin{noff+3};
                    obj.curvature = varargin{noff+4};
                    obj.slit_width= varargin{noff+5};
                    if nargin-noff>=6
                        obj.slit_spacing = varargin{noff+6};
                    else
                        obj.slit_spacing = obj.slit_width;
                    end
                    if nargin-noff>=8
                        obj.width = varargin{noff+7};
                        obj.height= varargin{noff+8};
                    end
                    if nargin-noff>=9
                        obj.energy = varargin{noff+9};
                    end
                    if nargin-noff>=10
                        obj.phase = varargin{noff+10};
                    end
                    if nargin-noff>=11
                        obj.jitter = varargin{noff+11};
                    end
                else
                    error('Check number of input arguments')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Set methods
        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('Fermi chopper name must be a character string (or empty string)')
            end
        end
        
        function obj=set.distance(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
            else
                error('Distance must be a numeric scalar')
            end
        end
        
        function obj=set.frequency(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.frequency_=val;
            else
                error('Frequency must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.radius(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.radius_=val;
            else
                error('Fermi chopper radius must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.curvature(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.curvature_=val;
            else
                error('Slit radius of curvature must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slit_width(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.slit_width_=val;
            else
                error('Slit width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slit_spacing(obj,val)
            if isscalar(val) && isnumeric(val) && val>=obj.slit_width
                obj.slit_spacing_=val;
            else
                error('Frequency must be a numeric scalar greater or equal to the slit width')
            end
        end
        
        function obj=set.width(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('Chopper aperture width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.height(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('Chopper aperture height must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.energy(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.energy_=val;
            else
                error('Energy must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.phase(obj,val)
            if islognumscalar(val)
                obj.phase_=logical(val);
            else
                error('Chopper phase type must be true or false (or 1 or 0)')
            end
        end
        
        function obj=set.jitter(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.jitter_=val;
            else
                error('Timing jitter must be a numeric scalar greater or equal to zero')
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end
        
        function val=get.distance(obj)
            val=obj.distance_;
        end
        
        function val=get.frequency(obj)
            val=obj.frequency_;
        end
        
        function val=get.radius(obj)
            val=obj.radius_;
        end
        
        function val=get.curvature(obj)
            val=obj.curvature_;
        end
        
        function val=get.slit_width(obj)
            val=obj.slit_width_;
        end
        
        function val=get.slit_spacing(obj)
            val=obj.slit_spacing_;
        end
        
        function val=get.width(obj)
            val=obj.width_;
        end
        
        function val=get.height(obj)
            val=obj.height_;
        end
        
        function val=get.energy(obj)
            val=obj.energy_;
        end
        
        function val=get.phase(obj)
            val=obj.phase_;
        end
        
        function val=get.jitter(obj)
            val=obj.jitter_;
        end

        %------------------------------------------------------------------
    end
end
