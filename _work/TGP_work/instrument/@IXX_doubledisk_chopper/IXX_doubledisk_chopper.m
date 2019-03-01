classdef IXX_doubledisk_chopper
    % Double disk chopper class definition
    
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
        slot_width_ = 0;
        aperture_width_ = 0;
        aperture_height_ = 0;
        jitter_ = 0;
        pdf_ = pdf_table();     % This is effectively a cached dependent variable
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        distance
        frequency
        radius
        slot_width
        aperture_width
        aperture_height
        jitter
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IXX_doubledisk_chopper (varargin)
            % Create double-disk chopper object
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
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin>=1
                noff=0;
                if is_string(varargin{1})
                    obj.name_ = varargin{1};
                    noff=noff+1;
                end
                if any(nargin-noff==[4,5,6,7])
                    obj.distance_  = varargin{noff+1};
                    obj.frequency_ = varargin{noff+2};
                    obj.radius_    = varargin{noff+3};
                    obj.slot_width_= varargin{noff+4};
                    if nargin-noff>=5
                        obj.aperture_width_ = varargin{noff+5};
                    else
                        obj.aperture_width_ = obj.slot_width_;
                    end
                    if nargin-noff>=6
                        obj.aperture_height_ = varargin{noff+6};
                    end
                    if nargin-noff>=7
                        obj.jitter_ = varargin{noff+7};
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
                error('Disk chopper name must be a character string (or empty string)')
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
                error('Disk chopper radius must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slot_width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.slot_width_=val;
            else
                error('Slot width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.aperture_width_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.aperture_width_=val;
            else
                error('Chopper aperture width must be a numeric scalar greater or equal to the slit width')
            end
        end
        
        function obj=set.aperture_height_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.aperture_height_=val;
            else
                error('Chopper aperture height must be a numeric scalar greater or equal to zero')
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
        
        function obj=set.slot_width(obj,val)
            val_old = obj.slot_width_;            
            obj.slot_width_=val;
            if obj.slot_width_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.aperture_width(obj,val)
            val_old = obj.aperture_width_;  
            obj.aperture_width_=val;
            if obj.aperture_width_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.aperture_height(obj,val)
            obj.aperture_height_=val;
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
        
        function val=get.slot_width(obj)
            val=obj.slot_width_;
        end
        
        function val=get.aperture_width(obj)
            val=obj.aperture_width_;
        end
        
        function val=get.aperture_height(obj)
            val=obj.aperture_height_;
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
            if ~isscalar(self), error('Method only takes a scalar double disk chopper object'), end
            pdf = self.pdf_;
        end
        
        %------------------------------------------------------------------
        
    end
end
