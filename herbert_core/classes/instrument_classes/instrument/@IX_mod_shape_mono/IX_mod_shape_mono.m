classdef IX_mod_shape_mono < serializable
    % Moderator - shaping chopper - monochromating chopper as a single object

    properties (Access=private)
        moderator_ = IX_moderator();
        shaping_chopper_ = IX_doubledisk_chopper();
        mono_chopper_ = IX_doubledisk_chopper();
        % The following are effectively cached dependent properties
        shaped_mod_ = false;
        t_m_offset_ = zeros(1,8);
        t_chop_av_ = zeros(2,8);
        t_chop_cov_ = zeros(2,2,8);
    end

    properties (Dependent)
        % Mirrors of private properties
        moderator
        shaping_chopper
        mono_chopper
        energy
        shaped_mod
    end
    properties (Dependent)
        % properties used in debugging
        t_m_offset;
        t_chop_av;
        t_chop_cov;
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_mod_shape_mono (varargin)
            % Create moderator-shaping chopper-monochromating chopper object
            %
            %   >> obj = IX_mod_shape_mono (moderator, shaping_chopper, mono_chopper)
            %   >> obj = IX_mod_shape_mono (moderator, shaping_chopper, mono_chopper, energy)
            %
            % Reuired:
            %   moderator       IX_moderator object
            %   shaping_chopper IX_doubledisk_chopper object
            %   mono_chopper    IX_doubledisk_chopper object
            %
            % Optional:
            %   energy          Neutron energy.
            %                   Default: taken from tne IX_moderator object


            % Original author: T.G.Perring


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_mod_shape_mono.loadobj(varargin{1});

            elseif nargin>=3
                flds = obj.saveableFields();
                flds = [flds(:);'energy']';
                [obj,remains] = set_positional_and_key_val_arguments(obj,...
                    flds,false,varargin{:});
                if ~isempty(remains)
                    error('HERBERT:IX_mod_shape_mono:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_mod_shape_mono constructor: %s',...
                        disp2str(remains));
                end

            elseif nargin~=0
                flds = obj.saveableFields();
                error('HERBERT:IX_mod_shape_mono:invalid_argument', ...
                    'IX_mod_shape_mono constructor requests at least 3 positional arguments, namely: %s', ...
                    disp2str(flds));
            end
        end

        %------------------------------------------------------------------
        % Set methods
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.moderator(obj,val)
            if ~isscalar(val) || ~isa(val,'IX_moderator')
                error('HERBERT:IX_mod_shape_mono:invalid_argument', ...
                    'Moderator must be scalar IX_moderator object')
            end
            obj.moderator_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(true);
            end
        end

        function obj=set.shaping_chopper(obj,val)
            if ~isscalar(val)
                error('HERBERT:IX_mod_shape_mono:invalid_argument', ...
                    'Moderator shaping chopper must be scalar')
            end
            obj.shaping_chopper_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(true);
            end
        end

        function obj=set.mono_chopper(obj,val)
            if ~isscalar(val)
                error('HERBERT:IX_mod_shape_mono:invalid_argument', ...
                    'Monochromating chopper must be scalar')
            end
            obj.mono_chopper_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(true);
            end
        end

        function obj=set.energy(obj,val)
            if ~(isscalar(val) && isnumeric(val) && val>=0)
                error('HERBERT:IX_mod_shape_mono:invalid_argument', ...
                    'Energy must be a scalar value greater than or equal to zero')
            end

            if val~=obj.moderator_.energy
                obj.moderator_.energy = val;
                if obj.do_check_combo_arg_
                    obj = obj.check_combo_arg(true);
                end
            end
        end
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.moderator(obj)
            val=obj.moderator_;
        end

        function val=get.shaping_chopper(obj)
            val=obj.shaping_chopper_;
        end

        function val=get.mono_chopper(obj)
            val=obj.mono_chopper_;
        end

        function val=get.energy(obj)
            val=obj.moderator_.energy;
        end

        function val=get.shaped_mod(obj)
            val=obj.shaped_mod_;
        end
        %------------------------------------------------------------------
        % for debugging
        function val=get.t_chop_av(obj)
            val = obj.t_chop_av_;
        end
        function val = get.t_m_offset(obj)
            val = obj.t_m_offset_;
        end
        function val = get.t_chop_cov(obj)
            val = obj.t_chop_cov_;
        end
    end

    methods(Hidden)
        %------------------------------------------------------------------
        % Private methods
        %------------------------------------------------------------------
        function status = recompute_shaped_mod_(obj)
            % Determine if the shaping chopper predominantly determines the
            % initial pulse width (i.e. status==true if the shaping chopper
            % pulse width is less than the scaled moderator pulse width at
            % the shaping chopper position)
            x1 = obj.mono_chopper_.distance;
            x0 = obj.moderator_.distance - x1;          % distance from mono chopper to moderator face
            xa = obj.shaping_chopper_.distance - x1;    % distance from shaping chopper to mono chopper
            [~,~,fwhh_moderator] = pulse_width(obj.moderator_);
            [~,fwhh_shaping_chopper] = pulse_width(obj.shaping_chopper_);
            % Determine the status is always determined e.g. if x0=xa=0 then
            % LHS of the logical statement is NaN which always results in
            % status==false
            status = ((x0/xa)*fwhh_shaping_chopper < fwhh_moderator);
        end
    end

    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            %
            flds =  {'moderator','shaping_chopper','mono_chopper'};
        end
        function obj = check_combo_arg(obj,do_recompute_components)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check

            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.
            if ~exist('do_recompute_components','var')
                do_recompute_components = true;
            end
            if do_recompute_components
                obj.shaped_mod_ = obj.recompute_shaped_mod_();
                obj.t_m_offset_ = obj.t_m_offset_calibrate_();
                [obj.t_chop_cov_, obj.t_chop_av_] = obj.moments_ ();
            end
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
            obj = IX_mod_shape_mono();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end
    %======================================================================

end
