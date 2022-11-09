classdef IX_moderator < serializable
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

    properties (Access=protected)
        name_ = '';
        distance_ = 0;
        angle_ = 0;
        pulse_model_ = 'delta_function';
        pp_ = [];
        flux_model_ = 'uniform';
        pf_ = [];
        flux_model_par_set_ = false(1,2);
        width_   =  0;
        height_    =  0;
        thickness_ = 0;
        temperature_ =  0;
        energy_ = 0;
        mandatory_field_set_ = false(1,4);
        pdf_ ;  % This is effectively a cached dependent variable
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
            %   >> moderator = IX_moderator (...,width,height,thickness,temperature,energy,name)
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
            % argument name (including abbrevioations).
            %
            %   >> moderator = IX_moderator (distance,angle,pulse_model,pp,...
            %               'energy',120,'temp',100)


            % Original author: T.G.Perring


            % Use the non-dependent property set functions to force a check of type, size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_moderator.loadobj(varargin{1});

            elseif nargin==0
                % Compute the pdf for the default object
                obj.pdf_ = recompute_pdf_(obj);

            elseif nargin>0
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                pos_params = obj.saveableFields();
                % process deprecated interface where the "name" property is
                % first among the input arguments
                if ischar(varargin{1})&&~strncmp(varargin{1},'-',1)&&~ismember(varargin{1},pos_params)
                    argi = varargin(2:end);
                    obj.name = varargin{1};
                else
                    argi = varargin;
                end
                % set positional parameters and key-value pairs and check their
                % consistency using public setters interface. check_compo_arg
                % after all settings have been done.
                [obj,remains] = set_positional_and_key_val_arguments(obj,pos_params,...
                    true,argi{:});
                if ~isempty(remains)
                    error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_fermi_chopper constructor: %s',...
                        disp2str(remains));
                end
            end
        end
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('IX_moderator:invalid_argument',...
                    'Moderator name must be a character string (or empty string)')
            end
        end

        function obj=set.distance(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
                obj.mandatory_field_set_(1)= true;
            else
                error('IX_moderator:invalid_argument',...
                    'Distance must be a numeric scalar')
            end
        end

        function obj=set.angle(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.angle_=val;
                obj.mandatory_field_set_(2)= true;
            else
                error('IX_moderator:invalid_argument',...
                    'Moderator face angle must be a numeric scalar')
            end
        end

        function obj=set.pulse_model(obj,val)
            obj = check_and_set_pulse_model_(obj,val);
        end

        function obj=set.pp(obj,val)
            obj = check_and_set_pm_param_(obj,val);
        end

        function obj=set.flux_model(obj,val)
            obj = check_and_set_flux_model_(obj,val);
        end

        function obj=set.pf(obj,val)
            obj = check_and_set_fm_params_(obj,val);
        end

        function obj=set.width(obj,val)
            obj = check_and_set_nonnegative_scalar_(obj,'width',val);
        end

        function obj=set.height(obj,val)
            obj = check_and_set_nonnegative_scalar_(obj,'height',val);
        end

        function obj=set.thickness(obj,val)
            obj = check_and_set_nonnegative_scalar_(obj,'thickness',val);
        end

        function obj=set.temperature(obj,val)
            obj = check_and_set_nonnegative_scalar_(obj,'temperature',val);
        end

        function obj=set.energy(obj,val)
            obj = check_and_set_nonnegative_scalar_(obj,'energy',val);
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
        function ver = classVersion(~)
            ver = 2;
        end
        function flds = saveableFields(~,mandatory)
            % Return cellarray of independent properties of the class
            %
            % If "mandatory" key is provided, return the subset of values
            % necessary for non-empty class to be defined
            if nargin>1
                mandatory = true;
            else
                mandatory = false;
            end

            flds =  {'distance','angle','pulse_model','pp',...
                'flux_model','pf','width','height','thickness',...
                'temperature','energy','name'};
            if mandatory
                flds = flds(1:4);
            end
        end
        function obj = check_combo_arg(obj,do_recompute_pdf)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check

            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.
            if ~exist('do_recompute_pdf','var')
                do_recompute_pdf = true;
            end            
            obj = check_combo_recalc_pdf_(obj,do_recompute_pdf);
        end

    end

    methods(Access=protected)
        %------------------------------------------------------------------
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_struct
            % function, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            inputs = convert_old_struct_(obj,inputs);
            % optimization here is possible to not to use the public
            % interface. But is it necessary? its the question
            obj = from_old_struct@serializable(obj,inputs);

        end
    end
    %
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available
            obj = IX_moderator();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end

end
