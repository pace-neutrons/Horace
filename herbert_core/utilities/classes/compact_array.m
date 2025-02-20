classdef compact_array < serializable
    %COMPACT_ARRAY intendent to store array with non-unique elements
    % e.g. val1,val2,val3:
    % [val1,val1,val2,val1,val2,val3,val3]
    % in the form:
    % {val1,val2,val3},{[1,2,4],[3,5],[6,7]}
    % where
    % val1, val2 and val3 are unique objects (including arrays of values or
    % objects)
    %
    % This is helper class to unique_*_containers for helping in operations
    % with these containers because the container themselves are incredibly
    % slow.

    properties(Dependent)
        n_unique         % number of unique objects
        n_objects        % total number of non-unique objects
        uniq_val         % cellarray of unique values
        nunq_idx         % cellarray of non-unique indices.
    end
    properties(Access=protected)
        uniq_val_
        nunq_idx_
        % cache for linear indices
        lidx_cache_;
    end

    methods
        function obj = compact_array(varargin)
            %COMPACT_ARRAY Construct an instance of this class
            %
            % Usage:
            % obj = compact_array(indices,values);
            %
            if nargin == 0
                return;
            end
            flds = obj.saveableFields();
            obj = set_positional_and_key_val_arguments (obj, ...
                flds, false, varargin{:});
        end
        %------------------------------------------------------------------
        function nu = get.n_unique(obj)
            nu = numel(obj.nunq_idx_);
        end
        function nn = get.n_objects(obj)
            lc = get_lidx(obj);
            nn = numel(lc);
        end
        %
        function val = get.uniq_val(obj)
            val = obj.uniq_val_;
        end
        function idx = get.nunq_idx(obj)
            idx = obj.nunq_idx_;
        end
        function obj = set.uniq_val(obj,val)
            if ~iscell(val)
                error('HERBERT:compact_array:invalid_argument',...
                    'Compact array values have to be wrapped in cellarray')
            end
            obj.uniq_val_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
        function obj = set.nunq_idx(obj,idx)
            if ~iscell(idx)
                error('HERBERT:compact_array:invalid_argument',...
                    'Compact array Indices have to be wrapped in cellarray')
            end
            obj.nunq_idx_ = idx;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %------------------------------------------------------------------
        function [nu,obj] = get_lidx(obj)
            if isempty(obj.lidx_cache_)
                pos     = [obj.nunq_idx_{:}];
                n_pos   = max(pos);
                lidx    = nan(1,n_pos);
                n_uniq = numel(obj.nunq_idx_);
                for i=1:n_uniq
                    lidx(obj.nunq_idx_{i}) = i;
                end
                obj.lidx_cache_ =lidx ;
            end
            nu = obj.lidx_cache_;
        end
        function [val,obj] = get(obj,lidx)
            % obtain object related to specifix non-unique index
            [lic,obj] = get_lidx(obj);
            val = obj.uniq_val_(lic(lidx));
        end

        function other_obj = get_subobj(obj,idx_to_select)
            % get other unique object which would contain
            % only indices, corresponding to the indices, provided as input

            n_uni = obj.n_unique;
            lidx = cell(1,n_uni);
            val = cell(1,n_uni);
            not_empty = true(1,n_uni);
            for i=1:n_uni
                selected = ismember(obj.nunq_idx_{i},idx_to_select);
                if any(selected)
                    val{i} = obj.uniq_val_{i};
                    lidx{i} = obj.nunq_idx_{i}(selected);
                else
                    not_empty(i) = false;
                end
            end
            other_obj = compact_array(lidx(not_empty),val(not_empty));
        end
    end
    %======================================================================
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
        %
        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = {'nunq_idx','uniq_val'};
        end
        %
        function obj = check_combo_arg(obj)
            % verify consistency of compact_array contents
            %
            % Inputs:
            % obj  -- the initialized instance of compact_array obj
            %
            % Returns: unchanged object if object is valid or throw error
            % if it does not

            if any(size(obj.uniq_val_)~=size(obj.nunq_idx_))
                error('HERBERT:compact_array:invalid_argument', ...
                    'Number of unique value fields have to be equal to number of its indices')
            end
            [~,obj] = get_lidx(obj);
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % save-able class
            obj = compact_array();
            obj = loadobj@serializable(S,obj);
        end
    end
end
