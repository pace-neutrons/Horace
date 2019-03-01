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
        %
        % We use a trick to cache the probability distribution function for
        % random sampling. It is a private non-dependent property, but is
        % recomputed whenever a public (and in this class) dependent property
        % is changed that could alter it.
        %
        % ***************************************************************
        %    WARNING: Do not change the value of any private property
        %             within a class method. This risks making pdf_
        %             out of synchronisation with the other properties.
        %             Only change the public properties, as this will force
        %             a recalculation.
        % ***************************************************************
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
        pdf_ = pdf_table();     % This is effectively a cached dependent variable
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
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IXX_fermi_chopper (varargin)
            % Create fermi chopper object
            %
            %   >> fermi_chopper = IX_fermi_chopper (distance,frequency,radius,curvature,slit_width)
            %
            %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing)
            %   >> fermi_chopper = IX_fermi_chopper (...,slit_spacing,width,height);
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
            
            % Original author: T.G.Perring
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin>=1
                noff=0;
                if is_string(varargin{1})
                    obj.name_ = varargin{1};
                    noff=noff+1;
                end
                if any(nargin-noff==[5,6,8,9,10,11])
                    obj.distance_  = varargin{noff+1};
                    obj.frequency_ = varargin{noff+2};
                    obj.radius_    = varargin{noff+3};
                    obj.curvature_ = varargin{noff+4};
                    obj.slit_width_= varargin{noff+5};
                    if nargin-noff>=6
                        obj.slit_spacing_ = varargin{noff+6};
                        if obj.slit_width_>obj.slit_spacing_
                            error('slit_spacing must be greater or equal to slit_width')
                        end
                    else
                        obj.slit_spacing_ = obj.slit_width_;
                    end
                    if nargin-noff>=8
                        obj.width_ = varargin{noff+7};
                        obj.height_= varargin{noff+8};
                    end
                    if nargin-noff>=9
                        obj.energy_ = varargin{noff+9};
                    end
                    if nargin-noff>=10
                        obj.phase_ = varargin{noff+10};
                    end
                    if nargin-noff>=11
                        obj.jitter_ = varargin{noff+11};
                    end
                else
                    error('Check number of input arguments')
                end
                % Compute the pdf
                obj.pdf_ = recompute_pdf_(obj);
            end
        end
        
        %------------------------------------------------------------------
        % Set methods
        %
        % Set the non-dependent properties. We cannot make the set
        % functions depend on other non-dependent properties (see Matlab
        % documentation). Have to devolve any checks on interdependencies to the
        % constructor (where we refer only to the non-dependent properties)
        % and in the set functions for the dependent properties. There is a
        % synchronisation that must be maintained as the checks in both places
        % must be identical.
        
        function obj=set.name_(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('Fermi chopper name must be a character string (or empty string)')
            end
        end
        
        function obj=set.distance_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
            else
                error('Distance must be a numeric scalar')
            end
        end
        
        function obj=set.frequency_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.frequency_=val;
            else
                error('Frequency must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.radius_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.radius_=val;
            else
                error('Fermi chopper radius must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.curvature_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.curvature_=val;
            else
                error('Slit radius of curvature must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slit_width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.slit_width_=val;
            else
                error('Slit width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slit_spacing_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.slit_spacing_=val;
            else
                error('Slit spacing must be a numeric scalar greater or equal to the slit width')
            end
        end
        
        function obj=set.width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('Chopper aperture width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.height_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('Chopper aperture height must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.energy_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.energy_=val;
            else
                error('Energy must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.phase_(obj,val)
            if islognumscalar(val)
                obj.phase_=logical(val);
            else
                error('Chopper phase type must be true or false (or 1 or 0)')
            end
        end
        
        function obj=set.jitter_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.jitter_=val;
            else
                error('Timing jitter must be a numeric scalar greater or equal to zero')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.name(obj,val)
            obj.name_=val;
        end
        
        function obj=set.distance(obj,val)
            obj.distance_=val;
        end
        
        function obj=set.frequency(obj,val)
            val_old = obj.frequency_;
            obj.frequency_=val;
            if obj.frequency_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.radius(obj,val)
            val_old = obj.radius_;
            obj.radius_=val;
            if obj.radius_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.curvature(obj,val)
            val_old = obj.curvature_;
            obj.curvature_=val;
            if obj.curvature_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.slit_width(obj,val)
            val_old = obj.slit_width_;
            
            obj.slit_width_=val;
            if obj.slit_width_>obj.slit_spacing_
                error('Slit width must be less than or equal to the slit spacing')
            end
            
            if obj.slit_width_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.slit_spacing(obj,val)
            obj.slit_spacing_=val;
            if obj.slit_spacing_<obj.slit_width_
                error('Slit spacing must be greater or equal to the slit width')
            end
        end
        
        function obj=set.width(obj,val)
            obj.width_=val;
        end
        
        function obj=set.height(obj,val)
            obj.height_=val;
        end
        
        function obj=set.energy(obj,val)
            val_old = obj.energy_;
            obj.energy_=val;
            if obj.energy_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.phase(obj,val)
            val_old = obj.phase_;
            obj.phase_=val;
            if obj.phase_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.jitter(obj,val)
            val_old = obj.jitter_;
            obj.jitter_=val;
            if obj.jitter_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
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
        function pdf = recompute_pdf_ (self)
            % Compute the pdf_table object if there is non-zero transmission
            npnt = 100;
            if self.transmission()>0
                [tlo, thi] = pulse_range(self);
                t = linspace(tlo,thi,npnt);
                y = pulse_shape(self, t);
                pdf = pdf_table(t,y);
            else
                pdf = pdf_table();
            end
        end
        
        %------------------------------------------------------------------
        % Recover pdf not as a property but via method
        function pdf = pdf_table(self)
            if ~isscalar(self), error('Method only takes a scalar Fermi chopper object'), end
            pdf = self.pdf_;
        end
        
        %------------------------------------------------------------------
        
    end
end
