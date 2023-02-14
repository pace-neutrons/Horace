classdef config_store < handle
    % Class provides single storage point for various configuration
    % classes.
    %
    % it stores/restores the classes, inheriting from config_base class
    %
    %
    properties(Dependent)
        % the full path to the folder where the configuration is stored
        config_folder;
        % property to observe config classes currently initiated in
        % the singleton (mainly for testing and debug purposes)
        config_classes;
        % the name of the folder where the configuration is stored;
        config_folder_name
    end

    properties(Access=private)
        config_folder_;
        config_storage_;
        saveable_;
        config_folder_name_ = 'mprogs_config';
    end

    methods(Static)
        function obj = instance(varargin)
            % Get instance of unique config_store implementation.
            %
            % Usage:
            % con = config_store.instance({[a_config_folder_name],'clear'})'
            % Where optional parameter does the following:
            % 'clear' -- removes all configurations from memory.
            % a_config_folder_name -- if present, sets the location of the
            %                         current config store in memory to the
            %                         folder provided
            %
            persistent unique_store_;
            if nargin>0
                unique_store_ = [];
                obj = [];
                if strcmp(varargin{1},'clear')
                    return;
                end
            end
            if isempty(unique_store_)
                obj = config_store(varargin{:});
                unique_store_ = obj;
            else
                obj = unique_store_;
            end
        end

        function set_config_folder(config_folder_name)
            % set the location for a folder with configuration to a location
            % provided as input.
            %
            % If the folder does not exist, its created. The configurations
            % currently in memory are retained but will be saved to the new
            % location on request only.
            if ~ischar(config_folder_name)
                error('CONFIG_STORE:invalid_argument',...
                    'config folder value has to be provided as a char string')
            end
            if strcmpi(config_folder_name,'clear')
                error('CONFIG_STORE:invalid_argument',...
                    'the config folder name can not be: ''clear''')
            end
            config_store.instance(config_folder_name);
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
                error('CONFIG_STORE:invalid_argument',mess);
            end
            store_internal(this,config_class,force_save,other_options{:});
        end

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
            %
            if isa(class_to_restore,'config_base')
                class_name = class_to_restore.class_name;
            elseif ischar(class_to_restore)
                class_name = class_to_restore;
                class_to_restore = feval(class_name);
            else
                error('CONFIG_STORE:invalid_argument',...
                    'Config class has to be a child of the config_base class or the name of such class');
            end

            if isfield(this.config_storage_,class_name)
                config_data = this.config_storage_.(class_name);
            else
                config_data = this.get_config(class_to_restore);
            end

            if numel(varargin) < nargout
                error('CONFIG_STORE:runtime_error',...
                    ' some output values are not set by this function call');
            end

            if isfield(config_data,varargin{1})
                val=config_data.(varargin{1});
            else
                warning('CONFIG_STORE:restore_config',...
                    'Class %s field %s is not stored in configuration. Returning defaults',...
                    class_name,varargin{1});
                val = class_to_restore.get_internal_field(varargin{1});
            end
            for i=2:nargout
                if isfield(config_data,varargin{i})
                    varargout{i-1}=config_data.(varargin{i});
                else
                    warning('CONFIG_STORE:restore_config',...
                        'Class %s field %s is not stored in configuration. Returning defaults',...
                        class_name,varargin{i});
                    varargout{i-1} = class_to_restore.get_internal_field(varargin{i});
                end
            end

        end

        function config_cont = get_all_configs(obj)
            % return all config info, currently loaded in memory
            config_cont = obj.config_storage_;

            fldn = fieldnames(config_cont);
            for i=1:numel(fldn)
                cfcl = feval(fldn{i});
                conf = cfcl.get_data_to_store();
                conf.saveable = obj.saveable_(fldn{i});
                config_cont.(fldn{i}) = conf;
            end
            config_cont.config_folder = obj.config_folder;
        end

        function set_all_configs(obj,config_struct)
            % set up config info, previously retrieved by get_all_configs
            % function into memory as current configuration
            %
            obj.config_folder_ = config_struct.config_folder;
            config_struct = rmfield(config_struct,'config_folder');

            fldn = fieldnames(config_struct);
            for i=1:numel(fldn)
                cfcl = feval(fldn{i});
                cfdata = config_struct.(fldn{i});
                saveable = cfdata.saveable;
                cfdata = rmfield(cfdata,'saveable');
                cl_fld = fieldnames(cfdata);
                cfcl.saveable = false;
                for j=1:numel(cl_fld)
                    cfcl.(cl_fld{j}) = cfdata.(cl_fld{j});
                end
                cfcl.saveable = saveable;
                if saveable
                    obj.save_config(fldn{i},cfcl.get_data_to_store());
                end
            end
        end

        %------------------------------------------------------------------
        % Two methods responsible for the class to be configured savable
        % savable property is not stored to HDD and is the property
        % of the object persistent until objects configuration is in memory
        function is = get_saveable(this,class_to_check)
            % returns true if a configuration class requested as input is savable
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
            % to set and the variable to_save is true if the class should be
            % made savable and false otherwise.
            %

            is_saveable= is_it > 0;

            if is_string(class_instance)
                class_name = class_instance;
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
            %>>val = ...
            %      config_store.instance().get_value(class_name,property_name)
            % or
            %>>[val1,val2,val3] = ...
            %       config_store.instance().get_value(class_name,...
            %                               property_name1,property_name2,property_name3);
            %
            [config_val,out] = this.get_config_val_internal(class_name,value_name,varargin);
            nout = max(nargout,1) - 1;
            for i=1:nout
                varargout{i} = out{i};
            end

        end

        function config_data=get_config(this,class_to_restore)
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
            % obj = conifg_store.instance().restore_config(hor_config)
            %       unusual instance of Herbert config, with modified
            %       defaults. Should not be used
            %
            % [use_mex,log_level]=conifg_store.instance().restore_config(hor_config,...
            %                     'use_mex','log_level')
            %                      returns current Herbert config settings for fields
            %                      'use_mex' and 'log_level'

            [config_data,read_from_file]=this.get_config_(class_to_restore);
            % execute class setters.

            % Important!!!
            % Despite we are not returning the resulting configuration,
            % executing this allows to set up global dependent fields (e.g.
            % set up unit test directories. But this can not set up
            % internal private dependent fields so a configuration can not
            % have such fields! (the setting got lost)

            % set active properties only if the data were recovered from
            % file
            if read_from_file
                if ~isa(class_to_restore,'config_base') % it mast be char
                    class_to_restore = feval(class_to_restore);
                end
                ss = class_to_restore.saveable;
                class_to_restore.saveable = false; % avoid resaving the data,
                % just loaded from disk
                class_to_restore.set_stored_data(config_data);
                class_to_restore.saveable = ss; % return saveable state to
                % its previous value
            end
        end

        function has = has_config(this,class_name)
            % method checks if the class with given name has given
            % configuration stored in file.
            % In other words, has a configuration been ever been changed from
            % defaults.
            conf_file = fullfile(this.config_folder,[class_name,'.mat']);
            has = is_file(conf_file);
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
                error('HERBERT:config_store:invalid_argument',mess);
            end
            clear_particular_config(this,class_instance,clear_file);
        end

        function clear_all(this,varargin)
            % clear all configurations, stored in memory.
            % if option -file exist, it also deletes all files related to
            % stored in memory configurations
            %
            options={'-files'};
            [ok,mess,clear_files]=parse_char_options(varargin,options);
            if ~ok
                error('HORACE:config_store:invalid_argument',mess);
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
                error('CONFIG_STORE:invalid_argument',mess);
            end
            %
            isit = check_isconfigured(this,class_instance,check_mem_only);
        end

        %------------------------------------------------------------------

        function path=get.config_folder(obj)
            path=obj.config_folder_;
        end
        function set.config_folder(obj,new_path)
            % simplified setter for config path. Always copies
            % old configuration to the new place
            obj.set_config_path(new_path);
        end

        function fn=get.config_folder_name(obj)
            fn = obj.config_folder_name_;
        end

        function set_config_path(obj,new_path,varargin)
            % set new config store path.
            % usage:
            % config_store.instance(new_path,['-clean']);
            %
            % Inputs:
            % new_path -- the path to store new configuration
            % Optional:
            % '-clean' -- existing configuration is unloaded from memory
            %             this option should be used within MPI workers
            %             to ensure they do not keep any spurions
            %             configuration in memory, and loaded shared
            %             configuration from config folder
            if ~(ischar(new_path)||isstring(new_path))
                error('HERBERT:config_store:invalid_argiment',...
                    'The input path has to be a char. Got : %s',fevalc('disp(new_path)'));
            end
            if nargin>2
                obj.instance(new_path);
            else
                obj.build_and_set_config_folder_(new_path);
            end
        end

        function storage = get.config_classes(this)
            storage = fieldnames(this.config_storage_);
        end

        function obj = save_config(obj,class_name,data_to_save)
            % save config class intormaion the appropriate config file
            if ~exist('data_to_save','var')
                data_to_save = obj.config_storage_.(class_name);
            end
            filename = fullfile(obj.config_folder,[class_name,'.mat']);
            [ok,mess]=save_config(filename,data_to_save);
            if ~ok
                error('HORACE:config_store:io_error',mess);
            end

        end

    end

    methods(Access=private)
        % Guard the constructor against external invocation.  We only want
        % to allow a single instance of this class.  See description in
        % Singleton superclass.
        function newStore = config_store(varargin)
            % create and initialize config_store;
            p = inputParser;
            addOptional(p, 'path', '', @(x)(validateattributes(x,...
                {'char', 'string'}, {'scalartext', 'nonempty'})));
            parse(p, varargin{:});
            new_path = p.Results.path;

            % initialize configurations storage.
            newStore.config_storage_ = struct();
            newStore.saveable_ = containers.Map();

            newStore=build_and_set_config_folder_(newStore,new_path);
        end

        function obj=build_and_set_config_folder_(obj,new_path)
            % construct the name of the config folder and set it up
            % as config folder at the path specified.
            %
            % If new_path does not exist or is not defined, build and set
            % config folder in default location, specified by
            % make_config_folder routine
            %
            % The default folder name incorporates the Horace version for
            % major version number greater than or equal to 4. This does
            % not include the case of the Jenkins build server, when the
            % default folder name incorporates the build name.

            %if ~exist('new_path','var') % not currently necessary as is
            %                              always called with new_path,
            %                              but to be aware of the futuire
            %    new_path = '';
            %end

            [is_jenk, build_name, workspace] = is_jenkins();
            if is_jenk
                % remove all possible folder paths of the build name
                % to be able to create valid file name.
                [~,build_name] = fileparts(build_name);
                obj.config_folder_name_ = ['mprogs_config_',build_name];

            else
                % analyze version number and if it exceeds the number
                % requested, specify other version folder.
                % To be extended in a future when verison number changes
                % and config folder either need changes or not.
                ver = herbert_version('-num');
                if ver >= 400
                    ver_string = '_v4';
                else
                    ver_string = '';
                end
                [is_virtual, type] = is_idaaas();

                if is_virtual
                    obj.config_folder_name_ = ['mprogs_config','_', type,ver_string];
                else
                    obj.config_folder_name_ = ['mprogs_config', ver_string];
                end
            end

            if ~isempty(new_path)
                [file_path,fn] = fileparts(new_path);
                if contains(fn,'mprogs_config') % use new path config folder
                    % name provided as input
                    obj.config_folder_name_ = fn;
                    use_external_path = true;
                else
                    use_external_path = false;
                end

                cfn = obj.config_folder_name;
                if use_external_path || strcmpi(fn,cfn)  % build config folder with the name,
                    % specified as defined on level up then
                    obj.config_folder_ = make_config_folder(cfn,file_path);
                else  % build config folder under the new path
                    obj.config_folder_ = make_config_folder(cfn,new_path);
                end
            else
                % Initialise default config folder path according to
                % configuration
                if is_jenk % build config folder on the Jenkins workspace
                    obj.config_folder_ = make_config_folder(obj.config_folder_name, workspace);
                else % build defailt config folder somewhere on available config path
                    obj.config_folder_ = make_config_folder(obj.config_folder_name);
                end
            end
        end
    end
end
