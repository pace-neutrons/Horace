classdef parallel_config<config_base
    %The config class contains the information about the parallel cluster
    %and the parallel framework available to run parallel Horace/Herbert
    %jobs
    %
    % To see the list of current configuration option values type:
    %   >> parallel_config
    %
    % To set values:
    %   >> set(parallel_config,'name1',val1,'name2',val2,...)
    % or just
    %   >>pc = parallel_config();
    %   >>pc.name1 = val1;
    %
    % To fetch values:
    %   >> [val1,val2,...]=get(parallel_config,'name1','name2',...)
    % or just
    %   >>
    %   >>val1 = pc.name1;
    %
    %parallel_config Methods:
    % ---------------------------------------------------------------------
    % worker               - The name of the script or program to run
    %                        on cluster in parallel using parallel
    %                        workers.
    %
    % is_compiled          - false if the worker is a matlab sctipt and
    %                        true if this script is compiled using Matlab
    %                        applications compiler.
    %
    % parallel_framework   - The name of a framework to use. Currently
    %                        available are h[erbert], p[arpool] and
    %                        [m]pi_cluster, frameworks
    %
    % cluster_config       - The configuration class describing parallel
    %                        cluster, running selected framework.
    %
    % shared_folder_on_local - The folder on your working machine containing
    %                         the job input and output data.
    %
    % shared_folder_on_remote - The place where your data should be found on
    %                          a remote worker.
    %
    % working_directory    - The folder, containing input data for the job
    %                        and tmp and output results should be stored.
    % ---------------------------------------------------------------------
    % known_frameworks     - Information method returning the list of
    %                        the parallel frameworks, known to Herbert.
    % known_clusters      -  Information method returning the list of
    %                        the clusters, available to run the selected
    %                        framework.
    % ---------------------------------------------------------------------
    % Type:
    %>>parallel_config  to see the list of current configuration option values.
    %
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    properties(Dependent)
        % The name of the script or program to run on cluster in parallel
        % using parallel workers. The script has to be on the Matlab search
        % path for all 
        worker;
        
        % False if the worker above is a matlab sctipt. The nodes need to
        % have  Matlab licenses or Matlab distributed cluster lisenses to
        % run this code.
        % True if the worker above is compiled using Matlab applications
        % compiler. The nodes need to have appropriate Matlab
        % redistributable installed to run this application.
        is_compiled;
        
        % The name of a framework to use for messages exchange. . Currently
        % available are h[erbert], p[arpool] and [m]pi_cluster frameworks.
        % where:
        %    [h]erbert --stands for Poor man MPI framework, which runs on a single
        %              node only and is actually not uses MPI, but launches
        %              separate Matlab sessions using Java Launcher.
        %              The sessions exchane information betweeneach other using
        %              file-based messages (.mat files), so this framework is
        %              not suitable for any tasks, demanding heavy interprocess
        %              communications.
        %    [p]arpool --Uses Matlab parallel computing toolbox and it parallel
        %              cluster configured as default to run parallel jobs.
        %              Refer to the parallel toolbox user's manual for the
        %              description of such clusters.
        %    [m]piexec_mpi-- Deploys MPI libraries and mpiexec to run parallel jobs.
        %              On Windows these libraries are provided with Herbert and
        %              configured for running the parallel jobs on a working node,
        %              but a linux machine needs these libraries installed and
        %              the framework compiled using herbert_mex_mpi script
        %              If the jobs are expected to run on more then
        %              one node, the nodes should be configured for MPI
        %              comminications (running mpiexec).
        %              Current framework is build and tested using MPICH v3.
        parallel_framework;
        
        % The configuration class describing parallel cluster, running
        % selected framework.
        % For herbert framework, the configuration name can only be 'local'
        % as herbert frameworks runs on a single node only. A parpool
        % cluster accepts only 'default' configuration, as the cluster
        % itself is selected using parallel computing toolbox GUI, while
        % mpi_cluster can accept 'local' configuration for jobs, running
        % locally or any configuration, defined in Herbert/admin/mpi_cluster_configs
        % folder. The files, provided there are the files to use as input
        % for mpiexec /gmachinefile <file_name> on Windows or
        % -f <file_name> on Linux. The property picks up the file and
        % assumes that the cluster configuration, defined there is correct.
        cluster_config;
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
        %------------------------------------------------------------------
        % Information fields, without setters:
        %------------------------------------------------------------------
        % true, if working directory have not ever been set
        wkdir_is_default
        % Information method returning the list of the parallel frameworks,
        % known to Herbert. You can not add or change a framework
        % using this method, The framework has to be defined and subscribed
        % via the algorithms factory.
        known_frameworks
        % Information method returning list of the known clusters,
        % available to run the selected framework.
        % For mpiexec_mpi framework, the cluster is defined
        % by a host file used as input for mpiexec (-f option).
        % These host files should be present in admin/mpi_cluster_configs
        % folder.
        % herbert framework runs only on a local cluster.
        % The cluster used by parpool framework is the default cluster,
        % selected in parallel computing toolbox GUI
        known_clusters
    end
    %
    properties(Constant,Access=private)
        saved_properties_list_={'worker','is_compiled',...
            'parallel_framework','cluster_config',...
            'shared_folder_on_local','shared_folder_on_remote','working_directory'};
        %-------------------------------------------------------------------
        % Subscription factory:
        % the list of the known framework names.
        known_frmwks_names_ = {'herbert','parpool','mpiexec_mpi'};
        % The map to exisiting parallel frameworks clusters
        known_frameworks_ = containers.Map(parallel_config.known_frmwks_names_,...
            {ClusterHerbert(),ClusterParpoolWrapper(),ClusterMPI()});
        % the map of the framework indexes
        frmwk_ids_ = containers.Map(parallel_config.known_frmwks_names_,...
            {1,2,3});
    end
    properties(Access=private)
        worker_ = 'worker_v1'
        is_compiled_ = false;
        % these values provide defaults for the properties above
        parallel_framework_   = 'herbert';
        % the configuration, used as default
        cluster_config_ = 'local';
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
        function wrkr = get.worker(obj)
            wrkr= get_or_restore_field(obj,'worker');
        end
        function wrkr = get.is_compiled(obj)
            wrkr= get_or_restore_field(obj,'is_compiled');
        end
        
        function frmw =get.parallel_framework(obj)
            frmw = get_or_restore_field(obj,'parallel_framework');
        end
        function conf = get.cluster_config(obj)
            conf = get_or_restore_field(obj,'cluster_config');
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
        %------------------------------------------------------------------
        function frmw = get.known_frameworks(obj)
            % Return list of frameworks, known to Herbert
            frmw = obj.known_frmwks_names_;
        end
        function clust = get.known_clusters(obj)
            % information about cluster configurations, available for the
            % selected framework
            fram = obj.parallel_framework;
            controller = obj.known_frameworks_(fram);
            clust  = controller.get_cluster_configs_available();
        end
        %
        %-----------------------------------------------------------------
        % overloaded setters
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
        %
        function obj = set.is_compiled(obj,val)
            val = logical(val);
            config_store.instance().store_config(obj,'is_compiled',val);
        end
        %
        function obj=set.parallel_framework(obj,val)
            % Set up MPI framework to use. Available options are:
            % h[erbert], p[arpool] or m[pi_cluster]
            % (can be defined by single symbol) or by a framework number
            % in the list of frameworks
            %
            opt = obj.known_frmwks_names_;
            the_name = select_option_(opt,val);
            theCluster = obj.known_frameworks_(the_name);
            % will throw PARALLEL_CONFIG:invalid_configuration if the
            % particular cluster is not available
            theCluster.check_availability();
            
            config_store.instance().store_config(...
                obj,'parallel_framework',the_name);
            all_configs = theCluster.get_cluster_configs_available();
            % if the config file is not among all existing configurations,
            % change current framework configuration to the default one for
            % the current framework.
            if ~ismember(all_configs,obj.cluster_config_)
                obj.cluster_config = all_configs{1};
            end
            % The default cluster configuration may be different for different
            % frameworks, so change default cluster configuration to the
            % one, suitable for the selected framework. 
            obj.cluster_config_ =all_configs{1};             
            
        end
        %
        function obj = set.cluster_config(obj,val)
            % select one of the clusters which configuration is available
            opt = obj.known_clusters;
            the_config = select_option_(opt,val);
            
            config_store.instance().store_config(obj,'cluster_config',the_config);
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
        %
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
        function controller = get_cluster_wrapper(obj,n_workers,cluster_to_host_exch_fmwork)
            % return the appropriate job controller
            log_level = config_store.instance.get_value('herbert_config','log_level');
            fram = obj.parallel_framework;
            controller = obj.known_frameworks_(fram);
            %
            controller = controller.init(n_workers,cluster_to_host_exch_fmwork,log_level);
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

