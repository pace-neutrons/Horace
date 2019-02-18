classdef IXX_moderator
    % Moderator class definition
    
    properties (Constant, Access=private)
        pulse_models_ = fixedNameList({'delta_function','ikcarp','ikcarp_param'})    % valid moderator pulse shape
        n_pp_ = containers.Map({'delta_function','ikcarp','ikcarp_param'},[0,3,3])     % number of parameters for pulse shape
        
        flux_models_ = fixedNameList('uniform')
        n_pf_ = containers.Map({'uniform'},0)
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
        angle_ = 0;
        pulse_model_ = 'delta_function';
        pp_ = [];
        flux_model_ = 'uniform';
        pf_ = [];
        width_ =  0;
        height_ =  0;
        thickness_ = 0;
        temperature_ =  0;
        energy_ = 0;
        pdf_ = pdf_table();     % This is effectively a cached dependent variable
        valid_ = true
    end
    
    properties (Dependent)
        % Mirrors of private properties
        name
        distance
        angle
        pulse_model
        pp
        flux_model
        pf
        width
        height
        thickness
        energy
        temperature
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IXX_moderator (varargin)
            % Create a moderator object
            %
            %   >> moderator = IX_moderator (distance,angle,pulse_model,pp)
            %   >> moderator = IX_moderator (distance,angle,pulse_model,pp,flux_model,pf)
            %   >> moderator = IX_moderator (...,width,height)
            %   >> moderator = IX_moderator (...,width,height,thickness)
            %   >> moderator = IX_moderator (...,width,height,thickness,temperature)
            %
            %   >> moderator = IX_moderator (name,...)
            %
            %   name            Name of the moderator (e.g. 'CH4')
            %   distance        Distance from sample (m) (+ve, against the usual convention)
            %   angle           Angle of normal to incident beam (deg)
            %                  (positive if normal is anticlockwise from incident beam)
            %   pulse_model     Model for pulse shape (e.g. 'ikcarp')
            %   pp              Parameters for the pulse shape model (array; length depends on pulse_model)
            %   flux_model      Model for flux profile (e.g. 'isis')
            %   pf              Parameters for the flux model (array; length depends on flux_model)
            %   width           Width of moderator (m)
            %   height          Height of moderator (m)
            %   thickness       Thickness of moderator (m)
            %   temperature     Temperature of moderator (K)
            %   energy          Energy of neutrons (meV)
            
            % Original author: T.G.Perring
            
            % Use the non-dependent property set functions to force a check of type, size etc.
            if nargin>=1
                noff=0;
                if is_string(varargin{1})
                    obj.name_ = varargin{1};
                    noff=noff+1;
                end
                if any(nargin-noff==[4,6,8,9,10,11])
                    obj.distance_  = varargin{noff+1};
                    obj.angle_ = varargin{noff+2};
                    obj.pulse_model_    = varargin{noff+3};
                    obj.pp_= varargin{noff+4};
                    if nargin-noff>=6
                        obj.flux_model_    = varargin{noff+5};
                        obj.pf_= varargin{noff+6};
                    end
                    if nargin-noff>=8
                        obj.width_ = varargin{noff+7};
                        obj.height_= varargin{noff+8};
                    end
                    if nargin-noff>=9
                        obj.thickness_ = varargin{noff+9};
                    end
                    if nargin-noff>=10
                        obj.temperature_ = varargin{noff+10};
                    end
                    if nargin-noff>=11
                        obj.energy_ = varargin{noff+11};
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
                error('Moderator name must be a character string (or empty string)')
            end
        end
        
        function obj=set.distance_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
            else
                error('Distance must be a numeric scalar')
            end
        end
        
        function obj=set.angle_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.angle_=val;
            else
                error('Moderator face angle must be a numeric scalar')
            end
        end
        
        function obj=set.pulse_model_(obj,val)
            if is_string(val) && ~isempty(val)
                [ok,mess,fullname] = obj.pulse_models_.valid(val);
                if ok
                    obj.pulse_model_=fullname;
                else
                    error(['Moderator pulse shape model: ',mess])
                end
            else
                error('Moderator pulse shape model must be a non-empty character string')
            end
        end
        
        function obj=set.pp_(obj,val)
            if isnumeric(val) && (isempty(val) || isvector(val))
                if isempty(val)
                    obj.pp_=[];
                else
                    obj.pp_=val(:)';    % make a row vector
                end
            else
                error('Moderator pulse shape parameters must be a numeric vector')
            end
        end
        
        function obj=set.flux_model_(obj,val)
            if is_string(val) && ~isempty(val)
                [ok,mess,fullname] = obj.flux_models_.valid(val);
                if ok
                    obj.flux_model_=fullname;
                else
                    error(['Moderator flux model: ',mess])
                end
            else
                error('Moderator flux model must be a non-empty character string')
            end
        end
        
        function obj=set.pf_(obj,val)
            if isnumeric(val) && (isempty(val) || isvector(val))
                if isempty(val)
                    obj.pf_=[];
                else
                    obj.pf_=val(:)';    % make a row vector
                end
            else
                error('Moderator flux model parameters must be a numeric vector')
            end
        end
        
        function obj=set.width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('Moderator width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.height_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('Moderator height must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.thickness_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.thickness_=val;
            else
                error('Moderator thickness must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.temperature_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.temperature_=val;
            else
                error('Moderator temperature must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.energy_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.energy_=val;
            else
                error('Selected energy must be a numeric scalar greater or equal to zero')
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
        
        function obj=set.angle(obj,val)
            obj.angle_=val;
        end
        
        function obj=set.pulse_model(obj,val)
            % Have to set the pulse model parameters to an invalid quantity if pulse model changes
            val_old = obj.pulse_model_;
            obj.pulse_model_=val;
            if ~strcmp(obj.pulse_model,val_old)
                obj.pp_ = NaN;
                obj.pdf_ = pdf_table();     % re-initialise
                obj.valid_ = false;
            end
        end
        
        function obj=set.pp(obj,val)
            % Must check the numnber of parameters is consistent with the pulse model
            val_old = obj.pp_;
            obj.pp_=val;
            if numel(obj.pp_)==obj.n_pp_(obj.pulse_model_)
                if ~all(obj.pp_==val_old)
                    obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
                end
                obj.valid_=true;
            else
                error('The number of pulse parameters is inconsistent with the pulse model')
            end
        end
        
        function obj=set.flux_model(obj,val)
            % Have to set the flux model parameters to an invalid quantity if sample shape changes
            val_old = obj.flux_model_;
            obj.flux_model_=val;
            if ~strcmp(obj.flux_model,val_old)
                obj.pf_ = NaN;
                obj.valid_ = false;
            end
        end
        
        function obj=set.pf(obj,val)
            % Must check the numnber of parameters is consistent with the flux model
            obj.pf_=val;
            if numel(obj.pf_)==obj.n_pf_(obj.flux_model_)
                obj.valid_=true;
            else
                error('The number of flux parameters is inconsistent with the flux model')
            end
        end
        
        function obj=set.width(obj,val)
            obj.thickness_=val;
        end
        
        function obj=set.height(obj,val)
            obj.temperature_=val;
        end
        
        function obj=set.thickness(obj,val)
            obj.thickness_=val;
        end
        
        function obj=set.temperature(obj,val)
            obj.temperature_=val;
        end
        
        function obj=set.energy(obj,val)
            obj.energy_=val;
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end
        
        function val=get.distance(obj)
            val=obj.distance_;
        end
        
        function val=get.angle(obj)
            val=obj.angle_;
        end
        
        function val=get.pulse_model(obj)
            val=obj.pulse_model_;
        end
        
        function val=get.pp(obj)
            val=obj.pp_;
        end
        
        function val=get.flux_model(obj)
            val=obj.flux_model_;
        end
        
        function val=get.pf(obj)
            val=obj.pf_;
        end
        
        function val=get.width(obj)
            val=obj.width_;
        end
        
        function val=get.height(obj)
            val=obj.height_;
        end
        
        function val=get.thickness(obj)
            val=obj.thickness_;
        end
        
        function val=get.temperature(obj)
            val=obj.temperature_;
        end
        
        function val=get.energy(obj)
            val=obj.energy_;
        end
        %------------------------------------------------------------------
    end
end
