classdef config_base
    % Base class for configurations, which have single instance for the whole
    % package and can be automatically stored/restored from hdd using
    % config_storage class
    %
    %
    % all derived classes used with configuration have to define two
    % abstract methods of this class (see below) and specify the setters
    % and getters for all stored properties in the following form:
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
    %
    %
    % $Revision$ ($Date$)
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
        
    end
    properties(Access=protected)
        % the name of the derived class with provides information to store
        class_name_ ;
        is_saveable_ = true;
        returns_defaults_=false;
    end
    %
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
        
        value = get_internal_field(this,field_name)
        % method gets internal field value bypassing standard get/set
        % methods interface
        %
        % For the example provided in the class description, this method
        % has to have a form:
        %
        %function value = get_internal_field(this,field_name)
        %   value = this.([field_name,'_']);
        %end
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
                error('CONFIG_BASE:constructor','first config_base variable has to be a string, providing the derived class name');
            end
        end
        %
        function name=get.class_name(this)
            name = this.class_name_;
        end
        function folder = get.config_folder(this)
            folder = config_store.instance.config_folder;
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
        %
        function this=set.saveable(this,val)
            config_store.instance.set_saveable(this,val);
        end
        %------------------------------------------------------------------
        function is = get.returns_defaults(this)
            is = this.returns_defaults_;
        end
        %
        function this=set.returns_defaults(this,val)
            if val > 0
                this.returns_defaults_=true;
            else
                this.returns_defaults_=false;
            end
        end
        function isit = is_default(this)
            % check if a configuration has been changed by user or
            % still has its default values
            cn = this.class_name;
            isit = ~config_store.instance.has_config(cn);
        end
        %------------------------------------------------------------------
        function value =get_or_restore_field(this,field_name)
            % method to restore value from config_store if available or
            % take default value from the class defaults if not
            
            % the method is used as the part of a standard derived class getter.
            
            if this.returns_defaults
                value = get_internal_field(this,field_name);
            else
                % get actual configuration
                % if class have never been stored in configuration, it
                % will return defaults
                value = config_store.instance.get_config_field(this,field_name);
            end
        end
        %
        function data=get_data_to_store(this)
            % method returns the structure with the data, expected to be stored
            % in configuration
            fields = this.get_storage_field_names();
            data=struct();
            for i=1:numel(fields)
                data.(fields{i}) = get_internal_field(this,fields{i});
            end
        end
        %
        function class_instance = set_stored_data(class_instance,data)
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
            fields = fieldnames(data);
            for i=1:numel(fields)
                field_name = fields{i};
                class_instance.(field_name) = data.(field_name);
            end
            
        end
    end
 
end


