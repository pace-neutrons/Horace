classdef unique_obj_store<handle
    %UNIQUE_OBJ_STORE contains unique objects used by
    %unique references container as the reference point.
    %
    %

    properties(Dependent)
        % number of unique types, placed in the storage
        n_types;
        % names of the unique objects, places in the store
        typenames;
        % number of unique objects of each type, located in the global store
        n_unique_per_type
    end
    properties(Dependent,Hidden=true)
        % number of objects of each type, located in the global store
        % This is for debugging only, as correctly working store should
        % contan unique objects only, so number of unique objects above
        % should be equal to number of each type objects
        n_obj_per_type
    end
    properties(Access=private)
        % structure, used for storing
        stor_holder_ = struct();
    end
    %----------------------------------------------------------------------
    % convenience interface
    methods
        function nt = get.n_types(obj)
            % Return number of unique types stored within the class
            nt = numel(fieldnames(obj.stor_holder_));
        end
        function fn = get.typenames(obj)
            % Return names of classes, stored within the storage
            fn = fieldnames(obj.stor_holder_)';
        end
        function nu = get.n_unique_per_type(obj)
            fn = fieldnames(obj.stor_holder_);
            nu = (cellfun(@(x)(obj.stor_holder_.(x).n_unique),fn))';
        end
        function nu = get.n_obj_per_type(obj)
            fn = fieldnames(obj.stor_holder_);
            nu = (cellfun(@(x)(obj.stor_holder_.(x).n_objects),fn))';
        end
    end
    %----------------------------------------------------------------------
    % store operations
    methods
        function stor = get_objects(obj,class_name)
            % return unique storage container for objects, defined by
            % specified class name
            if isfield(obj.stor_holder_,class_name)
                stor = obj.stor_holder_.(class_name);
            else
                stor = unique_only_obj_container(class_name);
            end
        end
        function obj = set_objects(obj,unique_storage)
            % return unique storage container for objects, defined by
            % specified class name
            if ~isa(unique_storage,'unique_only_obj_container')
                error('HERBERT:unique_obj_storage:invalid_argument', ...
                    'Only unique_only_obj_container may be set as storage of unique objects. Attempt to set %s', ...
                    class(unique_storage))
            end
            fldname = unique_storage.baseclass;
            if unique_storage.n_objects == 0 && ~isfield(obj.stor_holder_,fldname)
                % do not initialize storage by empty container. It is
                % unnecessary
                return;
            end
            obj.stor_holder_.(fldname) = unique_storage;
        end
        function val = get_value(obj,class_name,glidx)
            % return the value, stored in global memory at index provided
            % as input.
            % Throws if no such class store is currently in memory
            % or no object is stored at particular index.
            if ~isfield(obj.stor_holder_,class_name)
                error('HERBERT:unique_obj_store:invalid_argument',...
                    'Attempt to get value from emtpy store: %s',...
                    class_name);
            end
            stor = obj.stor_holder_.(class_name);
            if stor.is_in(glidx)
                val = stor(glidx);
            else
                error('HERBERT:unique_obj_store:invalid_argument',...
                    'Global index %d is outsie of the ranges [1,%d] of global store: %s', ...
                    glidx,stor.n_objects,class_name);
            end
        end
        function obj = clear(obj,class_name)
            % Clear from store particular type of unique objects
            % Input:
            % class_name  -- class name of the objects to remove from
            %                storage
            %
            % WARNING: calling this method would invalidate all
            % unique_rererences containers referring to this class.
            % USE CAREFULY, normally in tests, do avoid test side-effects
            %
            if isfield(obj.stor_holder_,class_name)
                obj.stor_holder_ = rmfield(obj.stor_holder_,class_name);
            end
        end
    end
    methods(Static)
        function obj = instance(varargin)
            % Get instance of unique unique_obj_store implementation.
            %
            % Usage:
            %>>con = unique_obj_store.instance(); returns unique instance
            % of the
            %
            % con = unique_obj_store.instance('clear');
            % Where optional parameter does the following:
            % 'clear' -- removes all configurations from memory.
            % a_config_folder_name -- if present, sets the location of the
            %                         current config store in memory to the
            %                         folder provided
            %
            persistent obj_holder_;
            if nargin>0
                obj_holder_ = [];
                obj = [];
                if strcmp(varargin{1},'clear')
                    return;
                end
            end
            if isempty(obj_holder_)
                obj = unique_obj_store(varargin{:});
                obj_holder_ = obj;
            else
                obj = obj_holder_;
            end
        end
        % the global container is a persistent struct in static method
        % global_container. This contains one field for each category (or
        % global name). Each field contains a unique_objects_container with
        % the relevant baseclass.

    end
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description of
        % Singleton class
        function obj= unique_obj_store(varargin)
            % create and initialize config_store;
            obj.stor_holder_ = struct();
        end

    end
end
