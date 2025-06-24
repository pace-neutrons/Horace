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
        % property describes the maximal grows limit for key-value
        % optimization array.
        %
        % The optimization works by allocating large contiguous array
        % (opt_array). The indices of this array (idx) are treated as keys
        % for values stored in the array, i.e. idx = key-min(keys)+1; so that
        % value1 for key1 is calculated as value1 =opt_array(key1-min(keys)+1)
        % The elements of opt_array array whith indices not equal to keys
        % contain NaN-s.
        % The property below shows how much more elements
        % the optimization array should contain wrt the number of keys in
        % the map. E.g. if empty_space_optimization_limit == 5 and there
        % are 100 keys, optimization array would contain no more than 500
        % elements. If this ratio is not satisfied, i.e.
        % if :
        % max(keys)-min(keys) > number_of_keys*empty_space_optimization_limit,
        %
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
        min_max_key; % minimal and maximal key values used in values
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
        min_max_key_  = []; % minimal and maximal values of keys in the
        % map. Used in building the the optimization indices
        keyval_optimized_ = {}; % 1D cellarray, containing values in places
        % of keys, used for fast access to the values instead of search
        % within key array.
        key_shif_;
        %
        key_conv_handle_ = @uint32
    end
    %----------------------------------------------------------------------
    methods
        function obj = fast_map(keys,values,varargin)
            % Constructor:
            % Usage:
            %>> fm = fast_map();
            %>> fm = fast_map(keys,values);
            %>> fm = fast_map(keys,values,key_type);
            % where :
            % keys      -- array or cellarray (numeric) keys
            % values    -- array or cellarray of (numeric) values
            % Optional:
            % key_type  -- string describing the type the keys should have
            %              Shold be selected from supported types, which
            %              are currently 'uint32','double' or 'uint64'
            if nargin == 0
                return;
            end
            obj.do_check_combo_arg_ = false;
            if nargin>2
                obj.KeyType = varargin{1};
            else
                if iscell(keys)
                    obj.KeyType = class(keys{1});
                else
                    obj.KeyType = class(keys);
                end
            end
            obj.keys   = keys;
            obj.values = values;
            obj.do_check_combo_arg_ = true;
            obj = obj.check_combo_arg();
        end
        function is = isKey(self,key)
            % Returns true if key is present within the keys of the object
            % and false otherwise.
            key = self.key_conv_handle_(key);
            present = self.keys_ == key;
            is = any(present);
        end
        function self = add(self,key,value)
            % add or replace value , corresponding to the key.
            % if there are no such key in the map, the key-value pair is
            % added to the map. If key is present, its current value is
            % replaced by the new one.
            key = self.key_conv_handle_(key);
            present =  self.keys_ == key;
            if any(present)
                self.values_(present) = value;
                if self.optimized_
                    self.keyval_optimized_(key-self.key_shif_) = value;
                end
            else
                self.keys_(end+1) = key;
                self.values_(end+1) = value;
                if self.optimized_
                    if key >= self.min_max_key_(1) && key<=self.min_max_key_(2)
                        self.keyval_optimized_(key-self.key_shif_) = value;
                    else
                        self.optimized = false;
                    end

                end
            end
        end
        function val = get(self,key)
            % retrieve value, which corresponds to key
            if self.optimized_
                val = self.keyval_optimized_(key-self.key_shif_);
            else
                key = self.key_conv_handle_(key);
                present = self.keys_ == key;
                if any(present)
                    val = self.values_(present);
                else
                    val = nan;
                end
            end
        end
        %
        function kt = get.KeyType(obj)
            kt = obj.key_type_;
        end
        function obj = set.KeyType(obj,type)
            if isnumeric(type)
                type = class(type);
            end
            switch(type)
                case('uint32')
                    obj.key_conv_handle_ = @uint32;
                case('uint64')
                    obj.key_conv_handle_ = @uint64;
                case('double')
                    obj.key_conv_handle_ = @double;
                otherwise
                    error('HORACE:fast_map:invalid_argument', ...
                        'Type %s as fast map key is not yet supported',type)
            end
            obj.key_type_ = type;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

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
                obj.min_max_key_ = [];
                obj.keyval_optimized_= [];
            end
        end
        %
        function mmv = get.min_max_key(obj)
            mmv = obj.min_max_key_;
        end
        function nm = get.n_members(obj)
            nm = numel(obj.keys_);
        end
        %
        function [val,key] = get_values_for_keys(self,keys,no_validity_checks,mode)
            % method retrieves values corresponding to array of keys.
            %
            % Using this method for array of keys is approximately
            % two-three times faster than retrieving array of values
            % invoking self.get(key(i)) method in a loop.
            %
            % Inputs:
            % self  -- initialized  instance of fast map class
            % keys  -- array of numerical keys
            % Optional:
            % no_validity_checks
            %       --  if true, keys assumed to be valid and validity
            %           check for keys is not performed (~5 times faster)
            %           Default -- do checks.
            % mode  --  2 numbers representing output modes. Default --
            %         mode == 1
            %    1  - expanded. return array have size of input keys array
            %         and nan values are returned for keys which are not
            %         present in the map.
            %    2  - compressed. Return array size equal to the number
            %         of present keys and keys which do not have
            %         correspondent values are omitted from the output.
            if nargin<3
                no_validity_checks = false;
            end
            if nargin<4
                mode = 1;
            end
            [val,key] = get_values_for_keys_(self,keys,no_validity_checks,mode);
        end

        function obj = optimize(obj,varargin)
            % Allocate cache array of size max(key)-min(key)+1 containing
            % NaNs and place values into locations where keys-min(key)+1
            % indices are present. This array is optimal for fast
            % access to the values as function of keys.
            if nargin == 1
                minmax_keys  = min_max(obj.keys_);
            else
                minmax_keys = varargin{1};
            end
            obj = optimize_(obj,minmax_keys);
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
                    ks = obj.key_conv_handle_(ks);
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
            ver = 2;
        end

        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = {'keys','values','KeyType'};
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
    methods(Access=protected)
        function [S,obj] = convert_old_struct (obj, S, ver)
            if ver == 1
                S.KeyType = 'uint32';
            end
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