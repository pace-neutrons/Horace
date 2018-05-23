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
    %  parallel_framework   - the name of a framework to use. Currently
    %                         availible are herbert or parpool, where
    %                         parpool works only if parallel computing
    %                         toolbox is installed and uses one while herbert
    %                         is custom herbert framework.
    % shared_folder_on_local- the folder on your working machine containing
    %                         the job input and output data mounted on
    %                         local machine and availible from the remote
    %                         machines.
    % shared_folder_on_remote- The place where your data should be found on
    %                         a remote worker.
    %                         the job input and output data mounted on
    %                         local machine and availible from the remote
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
    % $Revision: 630 $ ($Date: 2017-10-06 18:43:58 +0100 (Fri, 06 Oct 2017) $)
    %
    
    properties(Dependent)
        % a framework to use for message exchange. Currently availible are
        % herbert (herbert file-bases) and parpool (Matlab mpi) frameworks
        parallel_framework;
        %
        % the folder on your working machine containing the job input and
        % output data mounted on local machine and availible from the remote
        % machines.
        % Must have read/write permissions for all machines. Should be fast
        % /parlallel file system on a remote machines
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
        % If parallel horace job is deployed, the value of this directory
        % evaluated on a remote worker equal to
        % shared_folder_on_worker value
        working_directory
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'parallel_framework',...
            'shared_folder_on_local','shared_folder_on_remote','working_directory'};
    end
    properties(Access=private)
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
        
        %-----------------------------------------------------------------
        % overloaded setters
        function obj=set.parallel_framework(obj,val)
            % Set up MPI framework to use. Availible options are:
            % herbert or parpool.
            %
            opt = {'herbert','parpool'};
            [ok,err,is_herbert,is_partool,rest] = parse_char_options({val},opt);
            if ~isempty(rest)
                error('PARALLEL_CONFIG:invalid_argument',...
                    'Unknown option %s. Only ''herbert'' or ''parpool'' options are currently accepted',...
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
                check_and_set_parpool_framework_(obj);
            end
        end
        function obj=set.shared_folder_on_local(obj,val)
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
            if ~ischar(val)
                error('PARALLEL_CONFIG:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'shared_folder_on_remote',val);
        end
        
        
        function obj=set.working_directory(obj,val)
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
        function [controller,exit_worker_when_job_ends] = get_cluster_wrapper(obj,n_workers,cluster_to_host_exch_fmwork)
            % return the appropriate job controller
            fram = obj.parallel_framework;
            switch(fram)
                case('herbert')
                    controller = ClusterHerbert(n_workers,cluster_to_host_exch_fmwork);
                    exit_worker_when_job_ends = true;
                case('parpool')
                    controller = ClusterParpoolWrapper(n_workers,cluster_to_host_exch_fmwork);
                    exit_worker_when_job_ends = false;                    
                otherwise
                    error('PARALLEL_CONFIG:runtime_error',...
                        'Got unknown parallel framework: %s',fram);
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

