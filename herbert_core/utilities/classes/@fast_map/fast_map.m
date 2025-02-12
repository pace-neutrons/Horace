classdef fast_map < serializable
    %FAST_MAP class provides map functionality for small subset of
    %key-value pairs, where keys are unit32 numbers and values are double.
    %
    % Initial purpose -- use it as the fast map for connecting run_id-s with
    % IX_experiment number to maintain correspondence between IX_experiment
    % number and pixel ID.
    %
    % The class is necessary because MATLAB containers.Map class is
    % incredibly slow.
    %
    % Class optimized for key access rather then key insertion.
    % Further development and acceleration may be possible, including
    % mexing and building wrapper around C++ map class.
    %
    % WARNING: intentionally disabled multiple reliability checks and
    % convenience properties in favour of access speed.
    %
    % See fast_map_vs_map_performance in test_herbert_utilities
    % to compare speed and optimize fast_map operations.
    %
    properties
        % map optimization for doing fast access limit
        %
        % The map optimization works by allocating large continuous array
        % with places for keys as indices. Where keys correspond places in
        % array, result contains values, and where no keys present, array
        % contains nan-s. The property below shows how much more elements
        % the optimization array should contain wrt the number of keys in
        % the map. E.g. if empty_space_optimization_limit == 5 and there
        % are 100 keys, optimization array would contain no more than 500 
        % elements. If this ratio is not satisfied, i.e. 
        % if max(keys)-min(keys) > number_of_keys*empty_space_optimization_limit,
        % map optimization gets disabled and correspondence between keys
        % and values is calculated by binary search.
        empty_space_optimization_limit = 5;
    end

    properties(Dependent)
        n_members; % number of elements in key-value map
        keys       % arrays of keys used to retrieve the values
        values     % arrays of values which correspond to keys
        KeyType    % key type. Currently uint32 only
        optimized  % If true, map is optimized for faster access without
        %          % using binary search over keys
        % debugguging property
        min_max_key_val; % minimal and maximal key values used in values
        % access optimization
    end
    properties(Access=protected)
        key_type_ = 'uint32'
        val_type_ = 'double'
        keys_ = uint32([]); % array of keys, used to retrieve values
        values_=[]; % array of values, accessed through the keys
        %
        % Internal properties used in fast map optimization
        optimized_ = false;
        min_max_key_val_  = []; % minimal and maximal values of keys in the
        % map. Used in building the the optimization indices
        keyval_optimized_ = {}; % 1D cellarray, containing values in places
        % of keys, used for fast access to the values instead of search
        % within key array.
        key_shif_;
    end
    %----------------------------------------------------------------------
    methods
        function obj = fast_map(keys,values)
            % Constructor:
            % Usage:
            %>> fm = fast_map();
            %>> fm = fast_map(keys,values);
            % where :
            % keys      -- array or cellarray (numeric) keys
            % values    -- array or cellarray of (numeric) values
            if nargin == 0
                return;
            end
            obj.do_check_combo_arg_ = false;
            obj.keys   = keys;
            obj.values = values;
            obj.do_check_combo_arg_ = true;
            obj = obj.check_combo_arg();
        end
        function is = isKey(self,key)
            key = uint32(key);
            present = self.keys_ == key;
            is = any(present);
        end
        function self = add(self,key,value)
            % add or replace value , corresponding to the key.
            % if there are no such key in the map, the key-value pair is
            % added to the map. If key is present, its current value is
            % replaced by the new one.
            key = uint32(key);
            present =  self.keys_ == key;
            if any(present)
                self.values_(present) = value;
                if self.optimized_
                    self.keyval_optimized_(key-self.key_shif_) = value;
                end
            else
                self.keys_(end+1) = key;
                self.values_(end+1) = value;
                self.optimized = false;
            end
        end
        function val = get(self,key)
            % retrieve value, which corresponds to key
            if self.optimized_
                val = self.keyval_optimized_(key-self.key_shif_);
            else
                key = uint32(key);
                present = self.keys_ == key;
                if any(present)
                    val = self.values_(present);
                else
                    val = nan;
                end
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
            obj.keys_ = ks(:)';
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function val = get.values(obj)
            val = obj.values_;
        end
        function obj = set.values(obj,val)
            if iscell(val)
                val = [val{:}];
            end
            val = obj.check_values(val);

            obj.values_ = val(:)';
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function opt = get.optimized(obj)
            opt = obj.optimized_;
        end
        function obj = set.optimized(obj,do_opt)
            do_opt = logical(do_opt);
            if do_opt
                obj = obj.optimize();
            else
                obj.optimized_ = false;
                obj.min_max_key_val_ = [];
                obj.keyval_optimized_= [];
            end
        end
        %
        function mmv = get.min_max_key_val(obj)
            mmv = obj.min_max_key_val_;
        end
        function nm = get.n_members(obj)
            nm = numel(obj.keys_);
        end
        %
        function val = get_values_for_keys(self,keys,no_validity_checks)
            % method retrieves values corresponding to array of keys.
            %
            % Using this method for array of keys is approximately two
            % times faster than retrieving array of values invoking get(key)
            % method.
            %
            % Inputs:
            % self  -- initialized  instance of fast map class
            % keys  -- array of numerical keys
            % no_validity_checks
            %       --  if true, keys assumed to be valid and validity
            %           check for keys is not performed (~5 times faster)
            %           Invalid keys will still throw in optimized map but
            %           error will be less
            %
            %
            if nargin<3
                no_validity_checks = false;
            end
            if ~no_validity_checks && self.optimized_
                valid = keys<=self.min_max_key_val_(2) | keys<self.key_shif_;
                if ~all(valid)
                    error('HERBERT:fast_map:invalid_argument',...
                        'All input keys must be in the allowed keys range [%d,%d]', ...
                        self.min_max_key_val_);
                end
            end
            n_keys = numel(keys);

            key = uint32(keys);
            val = nan(size(keys));
            if self.optimized_
                kvo = self.keyval_optimized_;
                kvs = self.key_shif_;
                for idx = 1:n_keys
                    val(idx) = kvo(keys(idx)-kvs);
                end
            else
                ks = self.keys_;
                requested = ismember(ks,key);
                kv = self.values_;
                val = kv(requested);
            end
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
        function val = check_values(obj,val)
            if ~isnumeric(val)
                error('HERBERT:fast_map:invalid_argument', ...
                    'Only numeric values are currently implemented in fast_map. Your value type is: %s', ...
                    class(val));
            else
                if ~isa(val,obj.val_type_) % Change with changing val_type_
                    val = double(val);
                end
            end
        end
        %
        function obj = optimize(obj)
            % place values into expanded array or cellarray, containing
            % NaN or empty where keys are missing and values where
            % keys are present. This array/cellarray is optimal for fast
            % access to the values as function of keys.
            %
            obj = optimize_(obj);
        end
    end
    %----------------------------------------------------------------------
    % Overloaded indexers. DESPITE LOOKING NICE, adding them makes fast_map
    % 40-60 times slower even without using indexes itself. Disabled for this
    % reason, until, may be mex is written which would deal with fast part
    % of indices or we fully switch to MATLAB over 2021a, where you may    
    % overload subsasgn using inheritance and implemented abstract methods.
    %
    % fast_map_vs_map_performance settings : nkeys = 200, 
    %                                        n_operations = 40000
    %
    %  SAMPLE OF PERFORMANCE OF fast_map vrt MATLAB map (UINT map)
    %                         subsref/subsasgn : enabled    ! disabled
    %Find & Add keys to UINT        map   takes: 108.82sec  ! 106.53sec
    %Find & Add keys FAST MAP       map   takes: 372.73sec  !   6.75sec
    %Find       keys in UINT        map   takes:  29.36sec  !  29.46sec
    %Find    keys in FAST MAP       map   takes: 183.09sec  !   5.28sec
    %Find all keys in FAST MAP  non-opt   takes:   0.14sec  !   0.14sec
    %Find keys in FAST MAP opt      map   takes: 180.73sec  !   0.23sec
    %Find all keys in FAST MAP opt  map   takes:   0.045sec !   0.038sec
    methods
        % function varargout = subsref(self,idxstr)
        %     if ~isscalar(self) % input is array or cell of unique_object_containers
        %         [varargout{1:nargout}] = builtin('subsref',self,idxstr);
        %         return;
        %     end
        %     %overloaded indexing for retrieving object from container
        %     switch idxstr(1).type
        %         case {'()'}
        %             key = idxstr(1).subs{:};
        %             val = self.get(key);
        %             if isscalar(idxstr)
        %                 varargout{1} = val;
        %             else
        %                 idx2 = idxstr(2:end);
        %                 [varargout{1:nargout}] = builtin('subsref',val,idx2);
        %             end
        %         case '.'
        %             [varargout{1:nargout}] = builtin('subsref',self,idxstr);
        %     end % end switch
        % end % end function subsref
        % function self = subsasgn(self,idxstr,varargin)
        %     % overloaded indexing for placing object to map
        %     switch idxstr(1).type
        %         case {'()'}
        %             key = idxstr(1).subs{:};
        %             if ~isscalar(idxstr)
        %                 val  = self.get(key);
        %                 idx2 = idxstr(2:end);
        %                 val  = builtin('subsasgn',val,idx2,varargin{:});
        %             else
        %                 val = varargin{1}; % value to assign
        %             end
        %             self = self.add(key,val);
        %         case '.'
        %             self = builtin('subsasgn',self,idxstr,varargin{:});
        %     end
        % end % subsasgn
    end
    % SERIALIZABLE interface
    %------------------------------------------------------------------
    methods
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and .sqw data format. Each new version would presumably read
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