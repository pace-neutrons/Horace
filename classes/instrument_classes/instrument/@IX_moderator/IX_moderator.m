classdef IX_moderator
    % Moderator class definition
    
    properties (Constant, Access=private)
        % Number of parameters:
        %   - Inf means any number of parameters (including none), but which must all be numeric
        %   - NaN means any number of parameters (including none), which can be of any type
        
        pulse_models_ = fixedNameList({'delta_function','ikcarp','ikcarp_param','table'})    % valid moderator pulse shape
        n_pp_ = containers.Map({'delta_function','ikcarp','ikcarp_param','table'},[0,3,3,NaN])     % number of parameters for pulse shape
        
        flux_models_ = fixedNameList('uniform','table')
        n_pf_ = containers.Map({'uniform','table'},[0,NaN])
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
        class_version_ = 1;
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
        function obj = IX_moderator (varargin)
            % Create a moderator object
            %
            %   >> moderator = IX_moderator (distance,angle,pulse_model,pp)
            %   >> moderator = IX_moderator (distance,angle,pulse_model,pp,flux_model,pf)
            %   >> moderator = IX_moderator (...,width,height)
            %   >> moderator = IX_moderator (...,width,height,thickness)
            %   >> moderator = IX_moderator (...,width,height,thickness,temperature)
            %   >> moderator = IX_moderator (...,width,height,thickness,temperature,energy)
            %
            %   >> moderator = IX_moderator (name,...)
            %
            % Required:
            %   distance        Distance from sample (m) (+ve, against the usual convention)
            %   angle           Angle of normal to incident beam (deg)
            %                  (positive if normal is anticlockwise from incident beam)
            %   pulse_model     Model for pulse shape (e.g. 'ikcarp')
            %   pp              Parameters for the pulse shape model (array; length depends on pulse_model)
            %
            % Optional:
            %   flux_model      Model for flux profile (e.g. 'isis')
            %   pf              Parameters for the flux model (array; length depends on flux_model)
            %   width           Width of moderator (m)
            %   height          Height of moderator (m)
            %   thickness       Thickness of moderator (m)
            %   temperature     Temperature of moderator (K)
            %   energy          Energy of neutrons (meV)
            %
            %   name            Name of the moderator (e.g. 'CH4')
            % 
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the 
            % argument name (including abbrevioations) with a preceding hyphen e.g.
            %
            %   >> moderator = IX_moderator (distance,angle,pulse_model,pp,...
            %               '-energy',120,'-temp',100)

            
            % Original author: T.G.Perring
            
            
            % Use the non-dependent property set functions to force a check of type, size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_moderator.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','distance','angle','pulse_model','pp',...
                    'flux_model','pf','width','height','thickness',...
                    'temperature','energy'};
                [S, present] = parse_args_namelist ({namelist,{'char'}}, varargin{:});
                if present.name
                    obj.name_ = S.name;
                end
                if present.distance
                    obj.distance_ = S.distance;
                end
                if present.angle
                    obj.angle_ = S.angle;
                end
                if present.pulse_model
                    if present.pp
                        obj.pulse_model_ = S.pulse_model;
                        obj.pp_ = S.pp;
                    else
                        error('Must give pulse model and pulse model parameters together')
                    end
                end
                if present.flux_model
                    if present.pp
                        obj.flux_model_ = S.flux_model;
                        obj.pf_ = S.pf;
                    else
                        error('Must give flux model and flux model parameters together')
                    end
                end
                if present.width
                    obj.width_ = S.width;
                end
                if present.height
                    obj.height_ = S.height;
                end
                if present.thickness
                    obj.thickness_ = S.thickness;
                end
                if present.temperature
                    obj.temperature_ = S.temperature;
                end
                if present.energy
                    obj.energy_ = S.energy;
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
                obj.pp_=val;
            end
        end
        
        function obj=set.flux_model_(obj,val)
            if is_string(val)
                if ~isempty(val)
                    [ok,mess,fullname] = obj.flux_models_.valid(val);
                else
                    [ok,mess,fullname] = obj.flux_models_.valid('uniform');     % For backwards compatibility
                end
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
                obj.pf_=val;
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
                obj.pp_ = [];
                obj.pdf_ = pdf_table();     % re-initialise
                obj.valid_ = false;
            end
        end
        
        function obj=set.pp(obj,val)
            % Must check the number of parameters is consistent with the pulse model
            val_old = obj.pp_;
            obj.pp_=val;
            if isnumeric(obj.pp_) && numel(obj.pp_)==obj.n_pp_(obj.pulse_model_)
                obj.valid_=true;
                if ~(numel(obj.pp_)==numel(val_old) && all(obj.pp_==val_old))
                    obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
                end
            elseif isnumeric(obj.pp_) && isinf(obj.n_pp_(obj.pulse_model_))
                obj.valid_=true;
                if ~(numel(obj.pp_)==numel(val_old) && isequal(obj.pp_,val_old))
                    obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
                end
            elseif isnan(obj.n_pp_(obj.pulse_model_))
                obj.valid_=true;
                if ~isequal(obj.pp_,val_old)
                    obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
                end
            else
                error('The number or type of pulse parameters is inconsistent with the pulse model')
            end
        end
        
        function obj=set.flux_model(obj,val)
            % Have to set the flux model parameters to an invalid quantity if sample shape changes
            val_old = obj.flux_model_;
            obj.flux_model_=val;
            if ~strcmp(obj.flux_model,val_old)
                obj.pf_ = [];
                obj.valid_ = false;
            end
        end
        
        function obj=set.pf(obj,val)
            % Must check the number of parameters is consistent with the flux model
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
        
    end

    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStrucIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStrucIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end
