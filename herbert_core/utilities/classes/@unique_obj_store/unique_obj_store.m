classdef unique_obj_store<handle
    %UNIQUE_OBJ_STORE contains information about unique objects used by
    %unique references container as reference point
    %
    %

    properties(Dependent)
        % number of unique types, placed in the storage
        n_types;
        % names of the unique objects, places in the store
        typenames;
    end
    properties(Access=private)
        % structure, used for storing
        stor_holder_ = struct();
    end

    methods
        function nt = get.n_types(obj)
            % Return number of unique types stored within the class
            nt = numel(fieldnames(obj.stor_holder_));
        end
        function nt = get.typenames(obj)
            % Return names of classes, stored within the storage
            nt = fieldnames(obj.stor_holder_);
        end
        function stor = get_objects(obj,class_name)
            % return unique storage container for objects, defined by
            % specified class name
            if isfield(obj.stor_holder_,class_name)
                stor = obj.stor_holder_.(class_name);
            else
                stor = unique_objects_container(class_name);
            end
        end
        function obj = set_objects(obj,unique_storage)
            % return unique storage container for objects, defined by
            % specified class name
            if ~isa(unique_storage,'unique_objects_container')
                error('HERBERT:unique_obj_storage:invalid_argument', ...
                    'Only unique_object_container may be set as storage of unique objects. Attempt to set %s', ...
                    class(unique_storage))
            end
            fname = unique_storage.baseclass;
            obj.stor_holder_.(fname) = unique_storage;
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
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function obj= unique_obj_store(varargin)
            % create and initialize config_store;
            obj.stor_holder_ = struct();
        end

    end
end
