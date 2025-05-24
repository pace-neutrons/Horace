classdef unique_obj_store<handle
    %UNIQUE_OBJ_STORE contains all unique objects used by
    %unique references containers as the reference point.
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
        % structure, used for attaching various types of unique object
        % containers to it.
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
        function stor= get_objects(obj,class_name)
            % return unique storage container for objects, defined by
            % input class name
            %
            % if there are no such class name objects stored, returns
            % empty container of this class objects
            if isfield(obj.stor_holder_,class_name)
                stor = obj.stor_holder_.(class_name);
            else
                stor = unique_only_obj_container(class_name);
            end
        end
        function obj = set_objects(obj,unique_storage)
            % sets the unique objects container with unique objects
            % referred by unique_reference_container for further usave.
            %
            % Normally should be used after get_objects retrieve this
            % container and unque_references_container modified it
            %
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
            % return the value, stored in global memory in container defined
            % by its imput name at the input index.
            %
            % Throws if no such class store is currently in memory
            % or no object is stored at particular index.
            if ~isfield(obj.stor_holder_,class_name)
                error('HERBERT:unique_obj_store:invalid_argument',...
                    'Attempt to get value from empty store: %s',...
                    class_name);
            end
            stor = obj.stor_holder_.(class_name);
            if stor.is_in(glidx)
                val = stor.get_at_direct_idx(glidx);
            else
                error('HERBERT:unique_obj_store:invalid_argument',...
                    'Global index %d is outside of the ranges [1,%d] of global store: %s', ...
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
            % USE CAREFULY, normally in tests, to avoid test side-effects.
            % Store initial state of the container before the test and
            % restore it after the clearing the test contents.
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
            % of the container with all unique object containers attached
            % to it. It is handle, so it allows direct synchroneous global
            % modification of all its values on local copy of the object
            %
            % con = unique_obj_store.instance('clear');
            %
            % 'clear' -- removes all unique objects from memory.
            %         Invalidates all unuque_references_containers which
            %         use these objects.
            % DANGEROUS OPTION! normally should use Matlab's "clear all"
            %         instead.
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
