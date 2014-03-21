classdef config_base
    % Base class for configurations, which have single instance for the whole
    % package and can be automatically stored/restored from hdd using
    % config_storage class
    %
    %
    % $Revision: 313 $ ($Date: 2013-12-02 11:31:41 +0000 (Mon, 02 Dec 2013) $)
    %
    
    properties(Dependent)
        % property defines the name of the derived storage class
        class_name;
        % property specifies if changes to the class should be stored on
        % hdd to restore them later
        saveable;
        % if property is set to true, method returns default configurations
        return_defaults;
    end
    properties(Access=protected)
        % the name of the derived class with provides information to store
        class_name_ ;
        is_saveable_ = true;
        return_defaults_=false;
    end
    %
    methods(Abstract)
        data=get_data_to_store(class_instance)
        % method returns the structure with the data, expected to be stored
        % in config_store
        
        this=set_stored_data(class_instance,data)
        % method places the data, provided as second argument, into
        % the class storage. (the operation opposite to
        % get_data_to_store operation.
        %
        % it should not be used in the configuration file as allows to
        % create orphaned (not managed by config_store) configurations
        
        fields = get_storage_field_names(class_instance)
        % helper function returns the list of the names of the structure,
        % get_data_to_store returns
        
        value = get_internal_field(this,field_name)
        % method gets internal field value bypassing standard get/set
        % methods interface
    end
    methods
        function obj=config_base(class_name)
            % constructor Assept input parameter which should be
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
        %-----------------------------------------------------------------
        function is = get.saveable(this)
            is = this.is_saveable_;
        end
        %
        function this=set.saveable(this,val)
            if val > 0
                this.is_saveable_=true;
            else
                this.is_saveable_=false;
            end
        end
        %------------------------------------------------------------------
        function is = get.return_defaults(this)
            is = this.return_defaults_;
        end
        %
        function this=set.return_defaults(this,val)
            if val > 0
                this.return_defaults_=true;
            else
                this.return_defaults_=false;
            end
        end
        %------------------------------------------------------------------
        function value =get_or_restore_field(this,field_name)
            % method to restore value from config_store if availible or
            % take default value from the class defaults if not
            
            % the method is used as the part of a standard derived class getter.
            
            if this.return_defaults
                value = get_internal_field(this,field_name);
            else
                % if class have never been stored in configuration, it
                % will return defaults
                value = config_store.instance().restore_config(this,field_name);
            end
        end
        
    end
    
end

