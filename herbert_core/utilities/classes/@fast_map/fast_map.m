classdef fast_map < serializable
    %FAST_MAP class provides map functionality for small subset of
    %key-value pairs.
    %
    % Initial purpose -- use it as the map for connecting run_id-s with
    % IX_experiment number so that correspondence between
    %
    % The class is necessary because MATLAB containers.map works incredibly
    % slow.

    properties(Dependent)
        keys
        values
        KeyType
    end
    properties(Access=protected)
        key_type_ = 'uint32'
        val_type_ = ''
        keys_ = [];
        values_={};
    end
    %----------------------------------------------------------------------    
    methods
        function obj = fast_map(keys,values)
            %
            if nargin == 0
                return;
            end
            obj.do_check_combo_arg_ = false;
            obj.keys   = keys;
            obj.values = values;
            obj.do_check_combo_arg_ = true;
            obj = obj.check_combo_arg();
        end
        function obj = add(obj,key,value)
            key = obj.check_keys(key);

            present = self.keys_ == key;
            if any(present)
                obj.values_(present) = value;
            else
                obj.keys_(end+1) = key;
                obj.values_(end+1) = value;
            end
        end
        function val = get(self,key)
            present = self.keys_ == key;
            if any(present)
                val = self.values_(present);
            else
                val = [];
            end
        end
        function kt = get.KeyType(obj)
            kt = obj.key_type_;
        end
        %
        function ks = get.keys(obj)
            ks = obj.keys_;
        end
        function obj = set.keys(obj,ks)
            if iscell(ks)
                ks = [ks{:}];
            end
            ks = obj.check_keys(ks);
            obj.keys_ = ks;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function val = get.values(obj)
            val = obj.values_;
        end
    end
    methods(Access=protected)
        function ks = check_keys(obj,ks)
            if ~isnumeric(ks)
                error('HERBERT:fast_map:invalid_argument', ...
                    'Only numeric keys are currently implemented in fast_map. Your key type is: %s', ...
                    class(ks));
            else
                if ~isa(ks,obj.key_type_) % Change with changing key_type_
                    ks = uint32(ks);
                end
            end
        end
    end
    %----------------------------------------------------------------------
    % Overloaded indexers
    methods
        function varargout = subsref(self,idxstr)
            if ~isscalar(self) % input is array or cell of unique_object_containers
                [varargout{1:nargout}] = builtin('subsref',self,idxstr);
                return;
            end
            % overloaded indexing for retrieving object from container
            switch idxstr(1).type
                case {'()'}
                    key = idxstr(1).subs{:};
                    val = self.get(key);
                    if isscalar(idxstr)
                        varargout{1} = val;
                    else
                        idx2 = idxstr(2:end);
                        [varargout{1:nargout}] = builtin('subsref',val,idx2);
                    end
                case '.'
                    [varargout{1:nargout}] = builtin('subsref',self,idxstr);
            end % end switch
        end % end function subsref
        function self = subsasgn(self,idxstr,varargin)
            % overloaded indexing for placing object to map
            switch idxstr(1).type
                case {'()'}
                    key = idxstr(1).subs{:};
                    if ~isscalar(idxstr)
                        val  = self.get(key);
                        idx2 = idxstr(2:end);
                        val  = builtin('subsasgn',val,idx2,varargin{:});
                    else
                        val = varargin{1}; % value to assign
                    end
                    self = self.add(key,val);                    
                case '.'
                    self = builtin('subsasgn',self,idxstr,varargin{:});
            end
        end % subsasgn
    end    
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end

        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = {'keys','values'};
        end
        %
        function obj = check_combo_arg(obj)
            % runs after changing property or number of properties to check
            % the consistency of the changes against all other relevant
            % properties
            %
            obj = check_combo_arg_(obj);
        end
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = fast_map();
            obj = loadobj@serializable(S,obj);
        end
    end % static methods
end