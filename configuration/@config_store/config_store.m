classdef config_store < handle
    % Class provides single storage point for various configuration
    % classes.
    %
    
    % $Revision: 313 $ ($Date: 2013-12-02 11:31:41 +0000 (Mon, 02 Dec 2013) $)
    
    properties(Dependent)
        % the full path to the folder where the configuration is stored
        config_folder;
        % field allowing to observe config storage (mainly for testing and
        % debug purposes)
        config_storage;
    end
    properties(Constant=true)
        % the name of the folder where the configuration is stored;
        config_folder_name='mprogs_config';
    end
    properties(Access=private)
        config_folder_;
        config_storage_;
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
        end
    end
    
    methods(Static)
        function obj = instance(varargin)
            % Instance function concrete implementation.
            %
            persistent unique_config_store_;
            if nargin>0
                unique_config_store_ = [];
                obj = [];
                return;
            end
            if isempty(unique_config_store_)
                obj = config_store();
                unique_config_store_ = obj;
            else
                obj = unique_config_store_;
            end
        end
    end
    methods
        function store_config(this,config_class,varargin)
            % store configuration in memory and on file if requested.
            %
            % clonfig class which property saveable==true, are saved both
            % into  memory, and to the hdd.
            %
            % if option -forcesave (or -force is provided) file is saved
            % into disc regardless of its status in memory
            
            options={'-forcesave'};
            [ok,mess,force_save]=parse_char_options(varargin,options);
            if ~ok
                error('CONFIG_STORE:store_config',mess);
            end
            config_store_internal(this,config_class,force_save);
        end
        function obj=restore_config(this,class_to_restore)
            % return configuration from memory or load it from a file if such
            % configuration exist on file and not in memory
            %
            % class_to_restore -- the class instance of which should to be
            % restored from the hdd
            
            obj=restore_config_internal(this,class_to_restore);
        end
        %------------------------------------------------------------------
        function clear_config(this,class_instance,varargin)
            % clear configuration from memory
            %
            % if option -file exist, it also deletes the file
            % where this configuration is stored.
            %
            options={'-file'};
            [ok,mess,clear_file]=parse_char_options(varargin,options);
            if ~ok
                error('CONFIG_STORE:clear_config',mess);
            end
            clear_particular_config(this,class_instance,clear_file);            
        end
        %
        function clear_all(this,varargin)
            % clear all configurations, stored in memory.
            % if option -file exist, it also deletes all files with stored
            % configurations
            %            
            options={'-file'};
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
            % stored with the config_store
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
        function storage = get.config_storage(this)
            storage = fields(this.config_storage_);
        end
    end
end

