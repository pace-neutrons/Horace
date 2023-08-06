classdef IX_source < serializable
    % Neutron source information
    % Basic information about the source, such as name, target_name and
    % operating frequency

    properties (Access=private)
        name_ = '';         % Name of the source e.g. 'ISIS'
        target_name_ = '';  % Name of target e.g. 'TS1'
        frequency_ = 0;     % Operating frequency (Hz)
    end

    properties (Dependent)
        name            % Name of the source e.g. 'ISIS'
        target_name     % Name of target e.g. 'TS1'
        frequency       % Operating frequency (Hz)
    end
    properties(Constant,Access=protected)
        fieldsToSave_ = {'name','target_name','frequency'}
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_source (varargin)
            % Create source object e.g. ISIS target station 1
            %
            %   obj = IX_source (frequency)
            %   obj = IX_source (name,...)
            %   obj = IX_source (name, target_name,...)
            %
            % Optional:
            %   frequency       Source frequency
            %   name            Source name e.g. 'ISIS'
            %   target_name     Name of target e.g. 'TS2'
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbreviations) with a preceding hyphen e.g.
            %
            %   >> obj = IX_source ('ISIS','freq',50)

            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_source.loadobj(varargin{1});

            elseif nargin>0
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                if nargin == 1 && isnumeric(varargin{1})
                    obj.frequency = varargin{1};
                else
                    accept_params = obj.saveableFields();
                    [obj,remains] = set_positional_and_key_val_arguments(obj,...
                        accept_params,true,varargin{:});
                    if ~isempty(remains)
                        error('HERBERT:IX_source:invalid_argument', ...
                            'Unrecognized extra parameters provided as input to IX_source constructor: %s',...
                            disp2str(remains));
                    end
                end
            end
        end
        %

        %------------------------------------------------------------------
        % Set methods for independent properties
        %
        % Devolve any checks on interdependencies to the constructor (where
        % we refer only to the independent properties) and in the set
        % functions for the dependent properties.
        %
        % There is a synchronisation that must be maintained as the checks
        % in both places must be identical.

        function obj=set.name(obj,val)
            if isempty(val)
                val = '';
            end
            if istext(val)
                obj.name_ = char(val);
            else
                error('HERBERT:IX_source:invalid_argument',...
                    ['The source name must be a character string.\n' ...
                    ' Its type is: %s and value %s'], ...
                    class(val),disp2str(val))
            end
        end

        function obj=set.target_name(obj,val)
            if isempty(val)
                val = '';
            end

            if ~istext(val)
                error('HERBERT:IX_source:invalid_argument',...
                    ['The target name must be a character string.\n ' ...
                    ' Its type is: %s and value %s'], ...
                    class(val),disp2str(val))
            end
            obj.target_name_ = char(val);
        end

        function obj=set.frequency(obj,val)
            if isempty(val)
                val = 0;
            end
            if ~isnumeric(val) || ~isscalar(val) || val<0
                error('HERBERT:IX_source:invalid_argument',...
                    'The target frequency must be a non-negative number')
            end
            obj.frequency_ = val;
        end
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val = obj.name_;
        end

        function val=get.target_name(obj)
            val = obj.target_name_;
        end

        function val=get.frequency(obj)
            val = obj.frequency_;
        end
        %------------------------------------------------------------------
        function flds = saveableFields(obj)
            % Return cellarray of independent properties of the class
            flds = obj.fieldsToSave_;
        end
        function ver  = classVersion(~)
            % return current class version as it is stored on hdd
            ver = 2;
        end

    end
    methods(Sealed)
        function is = isempty(obj)
            % Assume that sample is empty if it was created with
            % empty constructor and has not been modified
            %
            % Assume that if a child is modified, it will also modify some
            % fields of the parent so the method will still work
            if numel(obj) == 0
                is = true;
                return;
            end
            is = false(size(obj));
            for i=1:numel(obj)
                if isempty(obj(i).name_) && isempty(obj(i).target_name_) && ...
                        obj(i).frequency_ == 0
                    is(i) = true;
                end
            end
        end

    end
    %======================================================================
    methods (Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj =IX_source();
            obj = loadobj@serializable(S,obj);

        end
        %------------------------------------------------------------------
    end
    methods(Access=protected)
        %------------------------------------------------------------------
        function [inputs,obj] = convert_old_struct(obj,inputs,ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised conversion. Called within
            % from_old_struct on each element of S and each obj in array of objects
            % (in case of serializable array of objects)
            inputs = convert_old_struct_(obj,inputs);
        end
    end

    %======================================================================
end
