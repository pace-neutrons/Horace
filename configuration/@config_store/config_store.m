classdef config_store < handle
    % Class provides single storage point for various configuration
    % classes.
    %
    % it stores/restores the classes, inheriting from config_base class
    %
    %
    %
    % $Revision: 313 $ ($Date: 2013-12-02 11:31:41 +0000 (Mon, 02 Dec 2013) $)
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
            config_store_internal(this,config_class,force_save,other_options{:});
        end
        %
        function  [val,varargout] = get_config_field(this,class_to_restore,varargin)
            %
            class_name = class_to_restore.class_name;
            
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
        
        function   config_data=get_config(this,class_to_restore)
            % return configuration from memory or load it from a file if such
            % configuration exist on file and not in memory
            %
            %
            % class_to_restore -- the class instance of which should to be
            % restored from the hdd
            %
            % if class_to_restore has option return_defaults==true,
            % default class configuration is returned
            %
            % if varargin is present, method returns not the clas itself, but
            % the range of the values of the class field names, specified in
            % the varargin.
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
            
            config_data=this.get_config_internal(class_to_restore);
            % execute class setters.
            
            % Important!!!
            % Despite we are not returning the resulting configuratio,
            % executing this allows to set up global dependent fields (e.g.
            % set up unit test directories. But this can not set up
            % internal privated dependent fields so a configuration can not
            % have such fields! (the setting got lost)
            class_to_restore.set_stored_data(config_data);
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

