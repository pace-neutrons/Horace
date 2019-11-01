classdef parallel_config<config_base
    % The class to configure Herbert parallel framework
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
    %  parallel_framework   - the name of a framework to use. Currently
    %                         available are Herbert or parpool, where
    %                         parpool works only if parallel computing
    %                         toolbox is installed and uses one while Herbert
    %                         is custom Herbert framework.
    % shared_folder_on_local- the folder on your working machine containing
    %                         the job input and output data mounted on
    %                         local machine and available from the remote
    %                         machines.
    % shared_folder_on_remote- The place where your data should be found on
    %                         a remote worker.
    %                         the job input and output data mounted on
    %                         local machine and available from the remote
    %                         machines.
    
    % working_directory     - The folder, containing input data for the job
    %                         and tmp and output results should be stored.
    %                         Must have read/write permissions. On remote
    %                         machines should contain data and store
    %                         output.
    %
    %
    % Type:
    %>>parallel_config  to see the list of current configuration option values.
    %
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties(Dependent)
        % The name of the script or program to run on cluster in parallel
        % using parallel workers
        worker;
        % a framework to use for message exchange. Currently available are
        % Herbert (Herbert file-bases) and parpool (Matlab MPI) frameworks
        parallel_framework;
        %
        % the folder on your working machine containing the job input and
        % output data mounted on local machine and available from the remote
        % machines.
        % Must have read/write permissions for all machines. Should be fast
        % /parallel file system on a remote machines
        %
        % If empty, assumed that the local machine filesystem is shared
        % with remote machine filesystem and have the same mounting points.
        shared_folder_on_local;
        %
        % The place where a job data should be found on a remote worker.
        % Must have read/write permissions for all machines.
        %
        % On a MPI worker should point to the physical location equal to
        % the specified by shared_folder_on_local property
        %
        % If empty, assumed to be equal to shared_folder_on_local.
        shared_folder_on_remote;
        %
        % Used as  the folder where tmp files should be stored in
        % parallel and non-parallel configuration.
        %
        % by default gen_sqw sets this value to place where spe files are
        % located.  If you never did gen_sqw on a given machine,
        % system tmp directory is used.
        %
        % Change this value to point to a fast&large disk or to a
        % parallel file system.
        % Assign empty value to restore it to default (system tmp
        % directory)
        %
        % If parallel Horace job is deployed, the value of this directory
        % evaluated on a remote worker equal to
        % shared_folder_on_worker value
        working_directory
        % true, if working directory have not ever been set
        wkdir_is_default
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'worker','parallel_framework',...
            'shared_folder_on_local','shared_folder_on_remote','working_directory'};
    end
    properties(Access=private)
        worker_ = 'worker_v1'
        % these values provide defaults for the properties above
        parallel_framework_   = 'herbert';
        % default remote folder is unset
        shared_folder_on_local_ ='';
        shared_folder_on_remote_ = '';
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
        %
        function folder =get.shared_folder_on_local(obj)
            folder = get_or_restore_field(obj,'shared_folder_on_local');
            if isempty(folder)
                is_depl = MPI_State.instance().is_deployed;
                if is_depl
                    folder = get_or_restore_field(obj,'working_directory');
                    if isempty(folder)
                        folder = tempdir;
                    end
                end
            end
        end
        %
        function folder =get.shared_folder_on_remote(obj)
            folder = get_or_restore_field(obj,'shared_folder_on_remote');
            if isempty(folder)
                folder = obj.shared_folder_on_local;
            end
        end
        
        function work_dir = get.working_directory(obj)
            is_depl = MPI_State.instance().is_deployed;
            if is_depl
                work_dir = obj.shared_folder_on_remote;
            else
                work_dir = get_or_restore_field(obj,'working_directory');
            end
            if isempty(work_dir)
                work_dir = tempdir;
            end
        end
        %
        function is = get.wkdir_is_default(obj)
            % returns true if working directory has not been set (points to
            % tmpdir)
            is_depl = MPI_State.instance().is_deployed;
            if is_depl
                work_dir = obj.shared_folder_on_remote;
            else
                work_dir = get_or_restore_field(obj,'working_directory');
            end
            if isempty(work_dir)
                is = true;
            else
                is = false;
            end
            
        end
        function wrkr = get.worker(obj)
            wrkr= get_or_restore_field(obj,'worker');
        end
        function obj = set.worker(obj,val)
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    'The worker property needs the executable script name')
            end
            scr_path = which(val);
            if isempty(scr_path)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The script to run in parallel (%s) should be available ',...
                    'to all running Matlab sessions but parallel config can not find it'],...
                    val)
            end
            config_store.instance().store_config(obj,'worker',val);
        end
        %-----------------------------------------------------------------
        % overloaded setters
        function obj=set.parallel_framework(obj,val)
            % Set up MPI framework to use. Available options are:
            % Herbert or parpool (can be defined by single symbol) 
            % or 
            %
            opt = {'herbert','parpool'};
            [ok,err,is_herbert,is_partool,rest] = parse_char_options({val},opt);
            if ~isempty(rest)
                error('PARALLEL_CONFIG:invalid_argument',...
                    'Unknown option: %s. Only ''h[erbert]'' or ''p[arpool]'' options are currently accepted',...
                    val);
            end
            if ~ok
                error('PARALLEL_CONFIG:invalid_argument',err);
            end
            if is_herbert
                config_store.instance().store_config(...
                    obj,'parallel_framework','herbert');
                return;
            end
            if is_partool
                [ok,err]=check_parpool_can_be_enabled(obj);
                if ok
                    config_store.instance().store_config(...
                        obj,'parallel_framework','parpool');
                else
                    error('PARALLEL_CONFIG:toolbox_licensing',err);
                end
            end
        end
        %
        function obj=set.shared_folder_on_local(obj,val)
            if isempty(val)
                val = '';
            end
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'shared_folder_on_local',val);
        end
        %
        function obj=set.shared_folder_on_remote(obj,val)
            if isempty(val)
                val = '';
            end
            
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'shared_folder_on_remote',val);
        end
        function data=get_data_to_store(obj)
            data = get_data_to_store@config_base(obj);
            % temp working directory should not be stored
            working_dir = data.working_directory;
            tdr = tempdir;
            if strncmpi(working_dir,tdr,numel(working_dir))
                data.working_directory = '';
            end
        end
        
        function obj=set.working_directory(obj,val)
            % Check and set working directory
            if isempty(val)
                val = '';
            end
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
        function [controller] = get_cluster_wrapper(obj,n_workers,cluster_to_host_exch_fmwork)
            % return the appropriate job controller
            log_level = config_store.instance.get_value('herbert_config','log_level');
            fram = obj.parallel_framework;
            switch(fram)
                case('herbert')
                    if log_level > -1
                        fprintf(':herbert configured: *** Starting Herbert (poor-man-MPI) cluster with %d workers ***\n',n_workers);
                    end
                    controller = ClusterHerbert(n_workers,cluster_to_host_exch_fmwork);
                    if log_level > -1
                        fprintf('*** Herbert cluster started                                 ***\n');
                    end
                case('parpool')
                    if log_level > -1
                        fprintf(':parpool configured: *** Starting Matlab MPI job  with %d workers ***\n',n_workers);
                    end
                    controller = ClusterParpoolWrapper(n_workers,cluster_to_host_exch_fmwork);
                    if log_level > -1
                        fprintf('*** Matlab MPI job started                 ***\n');
                    end
                otherwise
                    error('PARALLEL_CONFIG:runtime_error',...
                        'Got unknown parallel framework: %s',fram);
            end
        end
        
        function [ok,err]=check_parpool_can_be_enabled(obj)
            % check if parallel computing toolbox is available and can be
            % used
            [ok,err]=check_parpool_can_be_enabled_(obj);
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

