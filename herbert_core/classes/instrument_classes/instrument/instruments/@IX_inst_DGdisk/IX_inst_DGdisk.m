classdef IX_inst_DGdisk < IX_inst
    % Instrument with double disk shaping and monochromating choppers

    properties (Access=private)
        mod_shape_mono_ = IX_mod_shape_mono
        % instrument component fields set indicators for object to be valid
        mandatory_mod_fields_ = false(1,3);
        horiz_div_ = IX_divergence_profile
        vert_div_ = IX_divergence_profile
        % divergency component fields set indicators for object to be valid
        mandatory_div_fields_ = false(1,2);
    end

    properties (Dependent)
        mod_shape_mono  % Moderator-shaping chopper-monochromating chopper combination
        moderator       % Moderator (object of class IX_moderator)
        shaping_chopper % Moderator shaping chopper (object of class IX_doubledisk_chopper)
        mono_chopper    % Monochromating chopper (object of class IX_doubledisk_chopper)
        horiz_div       % Horizontal divergence lookup (object of class IX_divergence profile)
        vert_div        % Vertical divergence lookup (object of class IX_divergence profile)
        energy          % Incident neutron energy (meV)
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst_DGdisk (varargin)
            % Create double disk chopper instrument
            %
            %   obj = IX_inst_DGdisk (moderator, shaping_chopper, mono_chopper,...
            %               horiz_div, vert_div)
            %
            % Optionally:
            %   obj = IX_inst_DGdisk (..., energy)
            %
            %  one or both of:
            %   obj = IX_inst_DGdisk (..., 'name', name)
            %   obj = IX_inst_DGdisk (..., 'source', source)
            %
            %   moderator       Moderator (IX_moderator object)
            %   shaping_chopper Moderator shaping chopper (IX_doubledisk_chopper object)
            %   mono_chopper    Monochromating chopper (IX_doubledisk_chopper object)
            %   horiz_div       Horizontal divergence (IX_divergence object)
            %   vert_div        Vertical divergence (IX_divergence object)
            %   energy          Neutron energy (meV)
            %   name            Name of instrument (e.g. 'LET')
            %   source          Source: name (e.g. 'ISIS') or IX_source object

            % General case
            % make DGdisk not empty by default
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst_DGdisk.loadobj(varargin{1});

            elseif nargin>0
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names                
                accept_params = {'moderator','shaping_chopper','mono_chopper',...
                    'horiz_div','vert_div','energy','name','source',...
                    'valid_from','valid_to','mod_shape_mono'};
                % legacy interface processing name at the beginning of the
                % constructor.
                if ischar(varargin{1})&&~strncmp(varargin{1},'-',1)&&~ismember(varargin{1},accept_params)
                    argi = varargin(2:end);
                    obj.name = varargin{1};
                else
                    argi = varargin;
                end
                [obj,remains] = set_positional_and_key_val_arguments(obj,...
                    accept_params,true,argi{:});
                if ~isempty(remains)
                    error('HERBERT:IX_inst_DGdisk:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_inst_DGdisk constructor: %s',...
                        disp2str(remains));
                end
            end

        end
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.mod_shape_mono(obj,val)
            if isa(val,'IX_mod_shape_mono') && isscalar(val)
                obj.mod_shape_mono_ = val;
                obj.mandatory_mod_fields_ =true(1,3);
            else
                error('HERBERT:IX_inst_DGdisk:invalid_argument', ...
                    '''mod_shape_mono'' must be an IX_mod_shape_mono object')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        %------------------------------------------------------------------
        function obj=set.horiz_div(obj,val)
            if isa(val,'IX_divergence_profile') && isscalar(val)
                obj.horiz_div_ = val;
                obj.mandatory_div_fields_(1) =true;
            else
                error('HERBERT:IX_inst_DGdisk:invalid_argument', ...
                    'The horizontal divergence must be an IX_divergence_profile object')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        function obj=set.vert_div(obj,val)
            if isa(val,'IX_divergence_profile') && isscalar(val)
                obj.vert_div_ = val;
                obj.mandatory_div_fields_(2) =true;
            else
                error('HERBERT:IX_inst_DGdisk:invalid_argument', ...
                    'The vertical divergence must be an IX_divergence_profile object')
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        %------------------------------------------------------------------
        function obj=set.moderator(obj,val)
            obj.mod_shape_mono_.do_check_combo_arg = false;
            obj.mod_shape_mono_.moderator = val;
            obj.mandatory_mod_fields_(1) =true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        function obj=set.shaping_chopper(obj,val)
            obj.mod_shape_mono_.do_check_combo_arg = false;            
            obj.mod_shape_mono_.shaping_chopper = val;
            obj.mandatory_mod_fields_(2) =true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        function obj=set.mono_chopper(obj,val)
            obj.mod_shape_mono_.do_check_combo_arg = false;            
            obj.mod_shape_mono_.mono_chopper = val;
            obj.mandatory_mod_fields_(3) =true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        %
        function obj=set.energy(obj,val)
            obj.mod_shape_mono_.energy = val;
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.mod_shape_mono(obj)
            val = obj.mod_shape_mono_;
        end

        function val=get.moderator(obj)
            val = obj.mod_shape_mono_.moderator;
        end

        function val=get.shaping_chopper(obj)
            val = obj.mod_shape_mono_.shaping_chopper;
        end

        function val=get.mono_chopper(obj)
            val = obj.mod_shape_mono_.mono_chopper;
        end

        function val=get.horiz_div(obj)
            val = obj.horiz_div_;
        end

        function val=get.vert_div(obj)
            val = obj.vert_div_;
        end

        function val=get.energy(obj)
            val = obj.mod_shape_mono_.energy;
        end

        %------------------------------------------------------------------
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
    methods
        % SERIALIZABLE interface
        %---------------------------------------------------------
        function ver = classVersion(~)
            ver = 3;
        end

        function flds = saveableFields(obj)
            baseflds = saveableFields@IX_inst(obj);
            flds = ['mod_shape_mono',...
                'horiz_div','vert_div', baseflds];
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing dependent variables
            %  if requested.

            if ~all(obj.mandatory_mod_fields_)
                mod_fields = {'moderator','shaping_chopper','mono_chopper'};
                error('HERBERT:IX_inst_DGdisk:invalid_argument', ...
                    ['Mandatory fields (%s), defining mod_shape_mono class have not been set.\n',...
                    'set mod_shape_mono property or define the properties: %s'],...
                    disp2str(mod_fields),disp2str(mod_fields(~obj.mandatory_mod_fields_)))
            end
            if ~all(obj.mandatory_div_fields_)
                div_fields = {'horiz_div','vert_div'};
                error('HERBERT:IX_inst_DGdisk:invalid_argument', ...
                    'fields defining divirgence profile: %s have not been set.\nMissing fields are %s',...
                    disp2str(div_fields),disp2str(div_fields(~obj.mandatory_div_fields_)))
            end
            % verify the validity of mono_shape_mono moderator
            mcm = obj.mod_shape_mono;
            mcm.do_check_combo_arg = true;
            obj.mod_shape_mono_ = mcm.check_combo_arg();            
        end
    end
    %======================================================================
    % Custom loadobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

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
            obj = IX_inst_DGdisk();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------

    end
    %======================================================================


end
