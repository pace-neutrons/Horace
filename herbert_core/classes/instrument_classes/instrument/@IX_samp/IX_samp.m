classdef IX_samp  < hashable
    % Base class for samples to include the null sample case defined from a
    % structure with no fields (IX_null_sample) and the standard IX_sample

    properties (Access=protected)
        name_ = '';   % suitable string to identify sample
        alatt_;
        angdeg_;
    end

    properties
        %
    end

    properties (Dependent)
        % Mirrors of private/protected properties
        name;
        alatt;
        angdeg;
    end

    methods(Static)
        function isaval = cell_is_class(ca)
            try
                isaval = cellfun(@IX_samp.xxx, ca);
                if all(isaval), isaval = 1; else, isaval = 0; end
            catch
                error('HERBERT:IX_samp:cell_is_class', ...
                    'input could not be converted from cell to logical');
            end
        end
        function rv = xxx(obj)
            rv = isa(obj,'IX_samp');
        end
    end
    methods

        %------------------------------------------------------------------
        % Constructor, state
        %------------------------------------------------------------------
        function [obj,remains] = IX_samp (varargin)
            % Create base sample object
            % with possible arguments, 'name','alatt','angdeg';
            %
            %   >> base_sample = IX_samp (name)
            %
            if nargin==0
                return;
            end
            [obj,remains] = init(obj,varargin{:});
        end
        function  [obj,remains] = init(obj,varargin)
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
                false,argi{:});
        end
        function yesq = lattice_defined(self)
            yesq = ~isempty(self.alatt) && ~isempty(self.angdeg);
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

        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                if isempty(val)
                    obj.name_='';
                else
                    error('HERBERT:IX_samp:invalid_argument', ...
                        'Sample name must be a character string (or empty string)')
                end
            end
            obj = obj.clear_hash();
        end

        function name=get.name(obj)
            name = get_name(obj);
        end

        function obj=set.alatt(obj,val)
            if isempty(val)
                obj.alatt_ = [];
                obj = obj.clear_hash();
                return;
            end
            if ~isnumeric(val)
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample alatt must be a 1 or 3 compoment numeric vector')
            end

            if numel(val) == 1
                obj.alatt_ = [val,val,val];
            elseif numel(val) == 3
                obj.alatt_=val(:)';
            else
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample alatt must be a 1 or 3 compoment numeric vector')
            end
            obj = obj.clear_hash();
        end
        function alat=get.alatt(obj)
            alat = get_lattice(obj);
        end
        %
        function ang=get.angdeg(obj)
            ang = get_angles(obj);
        end
        function obj=set.angdeg(obj,val)
            if isempty(val)
                obj.angdeg_ = [];
                obj = obj.clear_hash();
                return;
            end
            if ~isnumeric(val)
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample angdeg must be a numeric vector')
            end

            if numel(val) == 1
                obj.angdeg_ = [val,val,val];
            elseif numel(val) == 3
                obj.angdeg_=val(:)';
            else
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample angdeg must be a numeric vector')
            end

            obj.angdeg_=val(:)';
            obj = obj.clear_hash();
        end
    end
    methods(Access = protected)
        function alat = get_lattice(obj)
            alat = obj.alatt_;
        end
        function ang = get_angles(obj)
            ang = obj.angdeg_;
        end
        function name = get_name(obj)
            name = obj.name_;
        end
    end
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    properties (Constant,Access=protected)
        % Stored properties - but kept protected (to allow children access)
        % and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        fields_to_save_ =  {'alatt', 'angdeg','name'};
    end
    methods
        function vers = classVersion(~)
            vers = 0; % base class function
        end

        function flds = saveableFields(~)
            flds =IX_samp.fields_to_save_;
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
            obj = IX_samp();
            obj = loadobj@serializable(S,obj);
        end

        %------------------------------------------------------------------

    end
    %======================================================================
end
