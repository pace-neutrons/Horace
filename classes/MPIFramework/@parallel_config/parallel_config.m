classdef parallel_config<config_base
    % The class to configure Herbert parlallel framework
    %
    % To see the list of current configuration option values:
    %   >> parallel_config
    %
    % To set values:
    %   >> set(parallel_config,'name1',val1,'name2',val2,...)
    % or just
    %   >>hc = parallel_config();
    %   >>hc.name1 = val1;
    %
    % To fetch values:
    %   >> [val1,val2,...]=get(parallel_config,'name1','name2',...)
    % or just
    %   >>val1 = parallel_config.name1;
    
    %
    % Fields are:
    % -----------
    %   parallel_framework  - the name of a framework to use. Currently
    %                         availible are herbert or parpool, where
    %                         parpool works only if parallel computing
    %                         toolbox is installed.
    %   remote_folder       - The folder as mounted on a cluste's parallel
    %                         file system containing input data for the jobs
    %                         and tmp and output results should be stored.
    %                         Must have read/write permissions.
    
    % Type:
    %>>parallel_config  to see the list of current configuration option values.
    %
    %
    % $Revision: 630 $ ($Date: 2017-10-06 18:43:58 +0100 (Fri, 06 Oct 2017) $)
    %
    
    properties(Dependent)
        % a framework to use for message exchange. Currently availible are
        % herbert (herbert file-bases) and parpool (Matlab mpi) frameworks
        parallel_framework;
        % the folder on a remote machine containing the job input and
        % output data as mounted on local machine. 
        % Must have read/write permissions for all machines. If empty, assumed
        % that local machine filesystem is shared with remote machine
        % filesystem.
        remote_folder_on_local;
        % the folder where tmp files should be stored.
        % by default gen_sqw sets this value to place where spe files are
        % located.  If you never did gen_sqw on a given machine,
        % system tmp directory is used.
        % Change this value to point to a fast&large disk or to a
        % parallel file system.
        % Assign empty value to restore it to default (system tmp
        % directory)
        % On a MPI worker  this directory will point to the physical
        % location defined by remote_folder_on_local property.
        working_directory        
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'parallel_framework',...
            'remote_folder_on_local','working_directory'};
    end
    properties(Access=private)
        % these values provide defaults for the properties above
        parallel_framework_   = 'herbert';
        % default remote folder is unset
        remote_folder_on_local_ ='';
        %
        working_directory_ ='';
    end
    methods
        function this = parallel_config()
            % constructor
            this=this@config_base(mfilename('class'));
        end
        %-----------------------------------------------------------------
        % overloaded getters
        function frmw =get.parallel_framework(obj)
            frmw = get_or_restore_field(obj,'parallel_framework');
        end
        function folder =get.remote_folder_on_local(obj)
            folder = get_or_restore_field(obj,'remote_folder_on_local');
        end
        function work_dir = get.working_directory(obj)
            work_dir = get_or_restore_field(obj,'working_directory');
            if isempty(work_dir)
                work_dir = tempdir;
            end
        end
        
        %-----------------------------------------------------------------
        % overloaded setters
        function obj =set.parallel_framework(obj,val)
            % Set up MPI framework to use. Availible options are:
            % matlab or parpool.
            %
            opt = {'herbert','parpool'};
            [ok,err,is_matlab,is_partool,rest] = parse_char_options({val},opt);
            if ~isempty(rest)
                error('PARALLEL_CONFIG:invalid_argument',...
                    sprinft('Unknown option %s',val));
            end
            if ~ok
                error('PARALLEL_CONFIG:invalid_argument',err);
            end
            if is_matlab
                config_store.instance().store_config(...
                    obj,'parallel_framework','herbert');
                return;
            end
            if is_partool
                check_and_set_parpool_framework_(obj);
            end
        end
        function obj =set.remote_folder_on_local(obj,val)
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'remote_folder_on_local',val);
        end
        function obj = set.working_directory(obj,val)
            % Check and set working directory
            if ~is_string(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    'working directory value should be a string')
            end
            if ~isempty(val)
                if strcmp(val,tempdir) % avoid storing tmp dir as working directory as this is default
                    val = '';
                else
                    test_dir = fullfile(val,'horace_test_write_directory');
                    clob = onCleanup(@()rmdir(test_dir,'s'));
                    ok = mkdir(test_dir);
                    if ~ok
                        warning('PARALLEL_CONFIG:invalid_argument',...
                            'working directory %s does not have write permissions. Changing it to %s directory',...
                            val,tempdir);
                        val = '';
                    end
                end
            end
            config_store.instance().store_config(obj,'working_directory',val);
        end
        
        %-----------------------------------------------------------------
        function controller = get_controller(obj)
            % return the appropriate job controller
            fram = obj.parallel_framework;
            switch(fram)
                case('herbert')
                    controller = JavaTaskWrapper();
                case('parpool')
                    controller = ParpoolTaskWrapper();
                otherwise
                    error('PARALLEL_CONFIG:runtime_error',...
                        'Get unknown parallel framework: %s',fram);
            end
        end
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            fields = this.saved_properties_list_;
        end
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = this.([field_name,'_']);
        end
    end
end

