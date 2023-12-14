classdef config_base
    % Base class for configurations, which have single instance for the whole
    % package and can be automatically stored/restored from hdd using
    % config_storage class
    %
    %
    % all derived classes used with configuration have to define two
    % abstract methods of this class:
    % 1)
    % helper function returns the list of the public properties,
    % which values one needs to store.
    %   fields = get_storage_field_names(class_instance)
    % 2)
    % method returns default property value idefined by condif class instance
    % ignoring current value, stored in common configuration and returned by
    % usual get.property method:
    % value = get_default_value(obj,field_name)
    %

    % And specify the setters and getters for all stored properties in
    % the following form:
    %
    % a) the property itself has to be defined as dependent e.g.:
    %
    % properties(Dependent)
    %     stored_poperty
    % end
    %
    % b) it has default value, which differs from the property itself.
    %
    %    If user supposes to use suggested abstract methods implementations,
    %    the name of the internal property with defaults
    %    has to be different from the public property name a) by the underscore
    %    at the end of its name
    %
    % properties(Access=private)
    %    stored_poperty_=default_value
    % end
    %
    % c) Its getter has the form:
    %function use = get.stored_poperty(this)
    %        use = get_or_restore_field(this,'stored_poperty');
    %end
    % d) Its setter has the form:
    %function this = set.stored_poperty(this,val)
    %       config_store.instance().store_config(this,'stored_poperty',val);
    %end
    %

    properties(Dependent)
        % property defines the name of the derived storage class. The
        % storage knows the stored configuration under this name.
        class_name;
        % property specifies if changes to the class should be stored on
        % hdd to restore them later
        saveable;
        % if this property is set to true, class getters return default configurations
        % instead of saved configurations
        returns_defaults;

        % the folder where the configuration data are stored (defined by
        % config store class, and provided here as an interface to it)
        config_folder;
        % similarly to serializable, allows disabling the check for
        % interdependent properties until they all have been set up.
        do_check_combo_arg
    end
    properties(Dependent,Hidden)
        % defines the list of properties, which never stored on HDD and
        % exist in memory only.
        % To define such properties, the child class should add the name of
        % the property to this list.
        mem_only_prop_list;

        % if true, issue warning if class have never been configured and
        % its values are choosen from defaults.
        warn_if_missing_config
        % If true, disables warnings issued during loading when
        % certain properties are set to a new, potentially invalid value.
        % Default -- false.
        disable_setup_warnings
    end

    properties(Access=protected)
        % the name of the derived class with provides information to store
        class_name_ ;
        is_saveable_ = true;
        returns_defaults_=false;
        do_check_combo_arg_ = true;
        % list of the properties, which never stored on hdd
        mem_only_prop_list_ = {};
        % issue warning if the configuration file is missing and this is
        % the first time you define the configuration, which is set to
        % defaults
        warn_if_missing_config_ = true;
        disable_setup_warnings_ = false;
    end

    methods(Abstract)
        fields = get_storage_field_names(class_instance)
        % helper function returns the list of the public properties,
        % which values one needs to store.
        %
        % For the example provided in the class description, this method
        % has to have a form:
        %
        %function fields = get_storage_field_names(class_instance)
        %   fields  = {stored_poperty};
        %end

        value = get_default_value(obj,field_name);
        % function value = get_default_value(obj,field_name)
        %     % method returns default property value idefined by config
        %     % class instance ignoring current value, stored in common
        %     % configuration and returned by usual get.property method.
        %     %
        %     % Default protected field names, corresponding to property names
        %     % normaly nave the form:
        %     % protected_prop_name = [public_prop_name,'_']
        %     % so default implementation of this function have the form:
        %     %
        %     value = obj.([field_name,'_']);
        % end

    end
    methods
        function obj=config_base(class_name)
            % constructor accepts input parameter which should be
            % the derived class name.
            %
            %Parameters:
            %class_name -- the string which defines the stored class name
            %
            if ischar(class_name)
                obj.class_name_ = class_name;
            else
                error('HERBERT:config_base:constructor', ...
                    'first config_base variable has to be a string, providing the derived class name');
            end
        end

        function name=get.class_name(this)
            name = this.class_name_;
        end

        function folder = get.config_folder(~)
            folder = config_store.instance.config_folder;
        end
        function obj=set.config_folder(obj,val)
            cfg = config_store.instance();
            cfg.config_folder = val;

            warning('HERBERT:temporary_config_path', ...
                '\n *** The config path: %s\n *** will last until the end of session or "clear classes" command is issued', ...
                cfg.config_folder)
        end
        %-----------------------------------------------------------------
        function is = get_saveable_default(this)
            % this method returns the default saveable state the
            % particular object
            % if object is not saveable, this method should be overloaded
            %
            is = this.is_saveable_;
        end

        function is=get.saveable(this)
            is = config_store.instance.get_saveable(this);
        end

        function this=set.saveable(this,val)
            config_store.instance.set_saveable(this,val);
        end
        %------------------------------------------------------------------
        function is = get.returns_defaults(this)
            is = this.returns_defaults_;
        end

        function this=set.returns_defaults(this,val)
            this.returns_defaults_ = val > 0;
        end
        %
        function do = get.do_check_combo_arg(obj)
            do = obj.do_check_combo_arg_;
        end
        function obj = set.do_check_combo_arg(obj,val)
            obj.do_check_combo_arg_ = logical(val);
        end
        %
        function mopl = get.mem_only_prop_list(obj)
            mopl = obj.mem_only_prop_list_;
        end
        %
        function do = get.warn_if_missing_config(obj)
            do = obj.warn_if_missing_config_;
        end
        function obj = set.warn_if_missing_config(obj,val)
            obj.warn_if_missing_config_ = logical(val);
        end
        %
        function disabled = get.disable_setup_warnings(obj)
            disabled = obj.disable_setup_warnings_;
        end
        function obj = set.disable_setup_warnings(obj,val)
            obj.disable_setup_warnings_ = logical(val);
        end
    end
    methods
        function isit = is_default(this)
            % check if a configuration has been changed by user or
            % still has its default values
            cn = this.class_name;
            isit = ~config_store.instance.has_config(cn);
        end
        function isit = is_field_configured(obj,field_name)
            isit = config_store.instance().is_field_configured(obj,field_name);
        end

        %------------------------------------------------------------------
        function value =get_or_restore_field(obj,field_name)
            % method to restore value from config_store if available or
            % take default value from the class defaults if not

            % the method is used as the part of a standard derived class getter.

            if obj.returns_defaults
                value = get_default_value(obj,field_name);
            else
                % get actual configuration
                % if class have never been stored in configuration, it
                % will return defaults
                value = config_store.instance.get_config_field( ...
                    obj,field_name);
            end
        end

        function data=get_defaults(obj)
            % method returns the structure with default class data,
            fields = obj.get_storage_field_names();
            data=struct();
            for i=1:numel(fields)
                data.(fields{i}) = get_default_value(obj,fields{i});
            end
        end

        function data=get_data_to_store(obj)
            % method returns the structure with the data, expected to be stored
            % in configuration
            fields = obj.get_storage_field_names();
            data=struct();
            for i=1:numel(fields)
                data.(fields{i}) = obj.(fields{i});
            end
        end
        function data = get_all_configured(obj)
            % return all configurable fields stored in memory
            fields1 = obj.get_storage_field_names();
            fields2 = obj.mem_only_prop_list;
            flds = [fields1(:);fields2(:)];
            for i=1:numel(flds)
                data.(flds{i}) = obj.(flds{i});
            end
        end

        function obj = set_stored_data(obj,data)
            % Method executes class setters for the config class_instance
            % using data structure provided as second argument
            %
            % data structure has to have fields with names equal to the
            % names of the class setters
            %
            % it can be used to load data from config store to config class
            % instance though such usage is not standard and should be used
            % for testing and debugging purposes only
            %
            obj.do_check_combo_arg = false;
            fields = fieldnames(data);
            for i=1:numel(fields)
                field_name = fields{i};
                obj.(field_name) = data.(field_name);
            end
            obj.do_check_combo_arg = true;
            obj = obj.check_combo_arg();
        end
        function obj = check_combo_arg(obj)
            % do validation of the interdependent properties
        end
    end
end
