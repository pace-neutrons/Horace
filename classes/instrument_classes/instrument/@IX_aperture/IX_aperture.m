classdef IX_aperture
    % Aperture class definition
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        
        name_ = '';
        distance_ = 0;
        width_ = 0;
        height_ = 0;
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        distance
        width
        height
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_aperture (varargin)
            % Create sample object
            %
            %   >> aperture = IX_aperture (distance, width, height)
            %   >> aperture = IX_aperture (name, distance, width, height)
            %
            %   name            Name of the aperture (e.g. 'in-pile')
            %   distance        Distance from sample (-ve if upstream, +ve if downstream)
            %   width           Full width of aperture (m)
            %   height          Full height of aperture (m)
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin>=1
                noff=0;
                if is_string(varargin{1})
                    obj.name_ = varargin{1};
                    noff=noff+1;
                end
                if nargin-noff==3
                    obj.distance_ = varargin{noff+1};
                    obj.width_    = varargin{noff+2};
                    obj.height_   = varargin{noff+3};
                else
                    error('Check number of input arguments')
                end
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
                error('Sample name must be a character string (or empty string)')
            end
        end
        
        function obj=set.distance_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
            else
                error('Distance must be a numeric scalar')
            end
        end
        
        function obj=set.width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('Aperture width must be a numeric scalar greater than or equal to zero')
            end
        end
        
        function obj=set.height_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('Aperture height must be a numeric scalar greater than or equal to zero')
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
        
        function obj=set.width(obj,val)
            obj.width_=val;
        end
        
        function obj=set.height(obj,val)
            obj.height_=val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end
        
        function val=get.distance(obj)
            val=obj.distance_;
        end
        
        function val=get.width(obj)
            val=obj.width_;
        end
        
        function val=get.height(obj)
            val=obj.height_;
        end
        
        %------------------------------------------------------------------
    end

end
