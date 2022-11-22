classdef IX_inst_DGfermi < IX_inst
    % Instrument with Fermi monochromating chopper

    properties (Access=private)
        aperture_ = IX_aperture
        fermi_chopper_ = IX_fermi_chopper
        moderator_ = IX_moderator
        % instrument component fields set indicators for object to be valid
        mandatory_inst_fields_ = false(1,3);
    end

    properties (Dependent)
        aperture        % Aperture (object of class IX_aperture)
        fermi_chopper   % Monochromating chopper (object of class IX_fermi_chopper)
        energy          % Incident neutron energy (meV)
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst_DGfermi (varargin)
            % Create Fermi chopper instrument
            %
            %   obj = IX_inst_DGfermi (moderator, aperture, fermi_chopper)
            %
            % Optionally:
            %   obj = IX_inst_DGfermi (..., energy)
            %
            %  one or both of:
            %   obj = IX_inst_DGfermi (..., 'name', name)
            %   obj = IX_inst_DGfermi (..., 'source', source)
            %
            %   moderator       Moderator (IX_moderator object)
            %   aperture        Aperture defining moderator area (IX_aperture object)
            %   fermi_chopper   Fermi chopper (IX_fermi_chopper object)
            %   energy          Neutron energy (meV)
            %   name            Name of instrument (e.g. 'LET')
            %   source          Source: name (e.g. 'ISIS') or IX_source object

            % General case
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst_DGfermi.loadobj(varargin{1});

            elseif nargin>0
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                accept_params = {'moderator','aperture','fermi_chopper','energy',...
                    'name','source','valid_from','valid_to'};
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
                    error('HERBERT:IX_inst_DGfermi:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_inst_DGfermi constructor: %s',...
                        disp2str(remains));
                end
            end
        end

        function obj=set.energy(obj,val)
            obj.moderator_.energy = val;
            obj.fermi_chopper_.energy = val;
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.aperture(obj,val)
            if isa(val,'IX_aperture') && isscalar(val)
                obj.aperture_ = val;
                obj.mandatory_inst_fields_(2)=true;
            else
                error('HERBERT:IX_inst_DGfermi:invalid_argument', ...
                    'The aperture must be an IX_aperture object It is: %s', ...
                    class(val))
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end

        function obj=set.fermi_chopper(obj,val)
            if isa(val,'IX_fermi_chopper') && isscalar(val)
                obj.fermi_chopper_ = val;
                obj.mandatory_inst_fields_(3)=true;
            else
                error('HERBERT:IX_inst_DGfermi:invalid_argument', ...
                    'The Fermi chopper must be an IX_fermi_chopper object It is: %s', ...
                    class(val))
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.aperture(obj)
            val = obj.aperture_;
        end

        function val=get.fermi_chopper(obj)
            val = obj.fermi_chopper_;
        end

        function val=get.energy(obj)
            val = obj.moderator_.energy;
        end
        %------------------------------------------------------------------
    end

    methods(Access=protected)
        function val = get_moderator(obj)
            val = obj.moderator_;
        end
        function obj = set_moderator(obj,val)
            % overloadable moderator setter
            if isa(val,'IX_moderator') && isscalar(val)
                obj.moderator_ = val;
                obj.mandatory_inst_fields_(1)=true;
            else
                error('HERBERT:IX_inst_DGfermi:invalid_argument', ...
                    'The moderator must be an IX_moderator object. It is: %s', ...
                    class(val))
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

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
        %-----------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end

        function flds = saveableFields(obj)
            baseflds = saveableFields@IX_inst(obj);
            flds = ['moderator','aperture', 'fermi_chopper', baseflds];
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing dependent variables
            %  if requested.

            if ~all(obj.mandatory_inst_fields_)
                mand_fields = {'moderator','aperture','fermi_chopper'};
                error('HERBERT:IX_inst_DGfermi:invalid_argument', ...
                    ['Mandatory fields (%s), defining IX_inst_DGfermi class have not been set.\n',...
                    'missing properties are: %s'],...
                    disp2str(mand_fields ),disp2str(mand_fields (~obj.mandatory_inst_fields_)))
            end
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
            obj = IX_inst_DGfermi();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------

    end
    %======================================================================

end
