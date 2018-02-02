classdef config_store < handle
    % Class provides single storage point for various configuration
    % classes.
    %
    % it stores/restores the classes, inheriting from config_base class
    %
    %
    %
    % $Revision$ ($Date$)
    %
    properties(Dependent)
        % the full path to the folder where the configuration is stored
        config_folder;
        % property to observe config classes currently initated in
        % the singleton (mainly for testing and debug purposes)
        config_classes;
    end
    properties(Constant=true)
        % the name of the folder where the configuration is stored;
        config_folder_name='mprogs_config';
    end
    properties(Access=private)
        config_folder_;
        config_storage_;
        saveable_;
    end
    
    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function newStore = config_store()
            % Initialise config folder path
            newStore.config_folder_ = make_config_folder(config_store.config_folder_name);
            % initialize configurations storage.
            newStore.config_storage_ = struct();
            newStore.saveable_ = containers.Map();
        end
    end
    
    methods(Static)
        function obj = instance(varargin)
            % Instance function concrete implementation.
            %
            persistent unique_store_;
            if nargin>0
                unique_store_ = [];
                obj = [];
                return;
            end
            if isempty(unique_store_)
                obj = config_store();
                unique_store_ = obj;
            else
                obj = unique_store_;
            end
        end
    end
    methods
        function store_config(this,config_class,varargin)
            % store configuration in memory and on file if requested.
            %
            % config_class class which property saveable==true, are saved both
            % into  memory, and to the hdd.
            %
            % if option -forcesave (or -force is provided) file is saved
            % into disc regardless of its status in memory
            
            options={'-forcesave'};
            [ok,mess,force_save,other_options]=parse_char_options(varargin,options);
            if ~ok
                error('CONFIG_STORE:store_config',mess);
            end
            store_internal(this,config_class,force_save,other_options{:});
        end
        %
        function  [val,varargout] = get_config_field(this,class_to_restore,varargin)
            % return the values of the requested field(s) from the
            % specified configuration file
            %Usage:
            %[field_val1,field_val2,...] =
            %        config_store.instance().get_config_field(config_class,field1,field2,....);
            % where:
            % config_class -- the configuration class or its name to get
            %                 values from.
            % field1,field2, etc... the names of the fields of the above
            %                       class to get their values.
            % Returns:
            % field_val1,field_val2, etc... -- the values of the requested
            %                                  fields
            if isa(class_to_restore,'config_base')
                class_name = class_to_restore.class_name;
            elseif ischar(class_to_restore)
                class_name = class_to_restore;
            else
                error('CONFIG_STORE:invalid_argument',...
                    'Config class has to be a chield of the config_base class');
            end
            
            if isfield(this.config_storage_,class_name)
                config_data = this.config_storage_.(class_name);
            else
                config_data = this.get_config(class_to_restore);
            end
            
            if numel(varargin) < nargout
                error('CONFIG_STORE:restore_config',' some output values are not set by this function call');
            end
            val=config_data.(varargin{1});
            for i=2:nargout
                varargout{i-1}=config_data.(varargin{i});
            end
            
        end
        %------------------------------------------------------------------
        % Two methods responsible for the class to be configured saveable
        % saveble property is not stored to HDD and is the property
        % of the object persistent untill objects configuration is in memory
        function is = get_saveable(this,class_to_check)
            % returns true if a configuration class requested as input is saveable
            % i.e. changes in configuration are stored on hdd
            % usage:
            %>>is = config_store.instance().get_saveable('class_name')
            %or 
            %>>is = config_store.instance().get_saveable(class_instance)
            %
            % where 'class_name' or class_instance is a configuration class
            % to check
            %
            if is_string(class_to_check)
                class_name  = class_to_check;
            else
                class_name = class_to_check.class_name;
            end
            if this.saveable_.isKey(class_name)
                is = this.saveable_(class_name);
            else
                is = class_to_check.get_saveable_default();
                this.saveable_(class_name)=is;
            end
        end
        function set_saveable(this,class_instance,is_it)
            % set or clear the property, which defines if the changes in
            % the class configuration are stored on hdd
            % usage:
            %>>config_store.instance().set_saveable('class_name',to_save)
            %or 
            %>>config_store.instance().set_saveable(class_instance,to_save)
            %
            % where 'class_name' or class_instance is a configuration class
            % to set and the variable to_save is true if the class shold be
            % made saveable and false otherwise. 
            %

            if is_it > 0
                is_saveable=true;
            else
                is_saveable=false;
            end
            if is_string(class_instance)
                class_name  = class_instance;
            else
                class_name = class_instance.class_name;
            end

            this.saveable_(class_name)=is_saveable;
        end
        %------------------------------------------------------------------
        function   [config_val,varargout] = get_value(this,class_name,value_name,varargin)
            % return specific config property value or list of values
            % from a config class, with specific class name
            %
            %Usage:
            %>>val =
            %      config_store.instance().get_value(class_name,property_name)
            % or
            %>>[val1,val2,val3] = config_store.instance().get_value(class_name,property_name1,property_name2,property_name3)
            %
            [config_val,out] = this.get_config_val_internal(class_name,value_name,varargin);
            nout = max(nargout,1) - 1;
            for i=1:nout
                varargout{i} = out{i};
            end
            
        end
        %
        function   config_data=get_config(this,class_to_restore)
            % return configuration from memory or load it from a file if such
            % configuration exist on file and not in memory
            %
            %
            % class_to_restore -- the class instance of which should to be
            % restored from the hdd or the name of this class.
            %
            % if class_to_restore has option returns_defaults==true,
            % default class configuration is returned
     
            %Usage:
            %
            % obj = conifg_store.instance().restore_config(herbert_config)
            %       unusual instance of herbert config, with modified
            %       detaults. Should not be used
            %
            % [use_mex,use_mex_C]=conifg_store.instance().restore_config(herbert_config,...
            %                     'use_mex','use_mex_C')
            %                     returns current herbert config settings for fields
            %                      'use_mex' and 'use_mex_C'
            
            config_data=this.get_config_(class_to_restore);
            % execute class setters.
            
            % Important!!!
            % Despite we are not returning the resulting configuration,
            % executing this allows to set up global dependent fields (e.g.
            % set up unit test directories. But this can not set up
            % internal privated dependent fields so a configuration can not
            % have such fields! (the setting got lost)
            class_to_restore.set_stored_data(config_data);
        end
        function has = has_config(this,class_name)
            % method checks if the class with given name has given
            % configuration stored in file.
            % In other words, has a configuration been ever been changed from
            % defaults.
            conf_file = fullfile(this.config_folder,[class_name,'.mat']);
            if exist(conf_file,'file')
                has = true;
            else
                has = false;
            end
        end
        %------------------------------------------------------------------
        function clear_config(this,class_instance,varargin)
            % clear configuration from memory
            %
            % if option -file exist, it also deletes the file
            % where this configuration is stored.
            %
            options={'-files'};
            [ok,mess,clear_file]=parse_char_options(varargin,options);
            if ~ok
                error('CONFIG_STORE:clear_config',mess);
            end
            clear_particular_config(this,class_instance,clear_file);
        end
        %
        function clear_all(this,varargin)
            % clear all configurations, stored in memory.
            % if option -file exist, it also deletes all files related to
            % stored in memory configurations
            %
            options={'-files'};
            [ok,mess,clear_files]=parse_char_options(varargin,options);
            if ~ok
                error('CONFIG_STORE:clear_config',mess);
            end
            if clear_files
                this.delete_all_files();
            end
            config_store.instance('clear');
        end
        function isit=is_configured(this,class_instance,varargin)
            % method checks if the class class_instance is
            % stored within the config_store
            %
            % if option -in_mem provided, it checks only if such configuration
            % is loaded in the memory
            
            options={'-in_mem'};
            [ok,mess,check_mem_only]=parse_char_options(varargin,options);
            if ~ok
                error('CONFIG_STORE:is_configured',mess);
            end
            %
            isit = check_isconfigured(this,class_instance,check_mem_only);
        end
        %------------------------------------------------------------------
        function path=get.config_folder(this)
            path=this.config_folder_;
        end
        %
        function storage = get.config_classes(this)
            storage = fieldnames(this.config_storage_);
        end
        
    end
end

