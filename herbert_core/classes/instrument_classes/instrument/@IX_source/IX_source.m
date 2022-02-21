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
            % argument name (including abbrevioations) with a preceding hyphen e.g.
            %
            %   >> obj = IX_source ('ISIS','-freq',50)
            
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_source.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','target_name','frequency'};
                [S, present] = parse_args_namelist...
                    ({namelist,{'char','char'}}, varargin{:});
                if present.name
                    obj.name = S.name;
                end
                if present.target_name
                    obj.target_name = S.target_name;
                end
                if present.frequency
                    obj.frequency = S.frequency;
                end
            end
        end
        %
        function iseq = eq(obj1,obj2)
            iseq = strcmp(obj1.name, obj2.name);
            iseq = iseq && strcmp(obj1.target_name, obj2.target_name);
            iseq = iseq && obj1.frequency==obj2.frequency;
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
            if is_string(val)
                obj.name_ = val;
            else
                error('HERBERT:IX_source:invalid_argument',...
                    'The source name must be a character string')
            end
        end
        
        function obj=set.target_name(obj,val)
            if isempty(val)
                val = '';
            end
            
            if ~is_string(val)
                error('The target name must be a character string')
            end
            obj.target_name_ = val;
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
        function flds = indepFields(obj)
            % Return cellarray of independent properties of the class
            flds = obj.propNamesIndep_;
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
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
                % here we rely on agreement that private independent
                % porperties have the same names as public properties but
                % have added suffix '_' at the end
                names_store = cellfun(@(x)x(1:end-1),...
                    names_store,'UniformOutput',false);
            end
            names = names_store;
        end
    end
    %------------------------------------------------------------------
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
            %
            obj = from_old_struct@serializable(obj,inputs);
            
        end
    end
    
    %======================================================================
end
