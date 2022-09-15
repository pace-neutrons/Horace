classdef parallel_config<config_base
    %The config class contains the information about the parallel cluster
    %and the parallel cluster available to run parallel Horace/Herbert
    %jobs
    %
    % To see the list of current configuration option values type:
    %   >> parallel_config
    %
    % To set values:
    %   >>pc = parallel_config();
    %   >>pc.name1 = val1;
    % or just
    %   >> set(parallel_config,'name1',val1,'name2',val2,...)
    %
    % To fetch values:
    %   >>pc = parallel_config();
    %   >>val1 = pc.name1;
    % or just
    %   >> [val1,val2,...]=get(parallel_config,'name1','name2',...)
    %
    %parallel_config Methods:
    % ---------------------------------------------------------------------
    % worker           - The name of the script or program to run
    %                    on cluster in parallel using parallel
    %                    workers.
    % is_compiled      - false if the worker is a Matlab script and
    %                    true if this script is compiled using Matlab
    %                    applications compiler.
    %
    % parallel_cluster   - The name of a cluster to use. Currently
    %                      defined are h[erbert], p[arpool],
    %                      [m]pi_cluster and [s]lurm_mpi clusters but they
    %                      may not be available on all systems.
    % cluster_config     - The configuration class describing parallel
    %                      cluster, running selected cluster.
    % threads            - How many computational threads to use in parallel
    %                      and in MEX
    % ---------------------------------------------------------------------
    % shared_folder_on_local - The folder on your working machine containing
    %                          the job input and output data.
    %
    % shared_folder_on_remote - The place where job input and ouptut data
    %                           should be found on (shared_folder_on_local)
    %                           a remote worker.
    %
    % working_directory    - The folder, containing input data for the job
    %                        and tmp and output results should be stored.
    %                        View from a remote worker.
    % ---------------------------------------------------------------------
    % external_mpiexec     - if cpp_communicator is compiled with MPI,
    %                        installed on system rather then the one,
    %                        provided with Herbert,the full name (with path)
    %                        to mpiexec program used to run parallel job
    %            Used ony when  parallel_cluster=='mpiexec_mpi'
    % =====================================================================
    % known_clusters       - Information method returning the list of
    %                        the parallel clusters, known to Herbert.
    % known_clust_configs  - Information method returning the list of
    %                        the configurations, available for the selected
    %                        cluster.
    % ---------------------------------------------------------------------
    % Type:
    %>>parallel_config  to see the list of current configuration option values.

    properties(Dependent)
        % The name of the script or program to run on cluster in parallel
        % using parallel workers. The script has to be on the Matlab search
        % path for all
        worker;

        % False if the worker above is a Matlab script. The nodes need to
        % have  Matlab licenses or Matlab distributed cluster licenses to
        % run this code.
        % True if the worker above is compiled using Matlab applications
        % compiler. The nodes need to have appropriate Matlab
        % redistributable installed to run this application.
        is_compiled;

        % The name of a cluster to use for messages exchange. . Currently
        % available are h[erbert], p[arpool] and [m]pi_cluster-s .
        % where:
        %    [h]erbert -- Poor man's MPI cluster, which runs on a single
        %              node only. Launches separate Matlab sessions using Java
        %              Launcher, which exchange information using
        %              file-based messages (.mat files), so this cluster is
        %              not suitable for any tasks, demanding heavy interprocess
        %              communications.
        %    [p]arpool -- Uses Matlab parallel computing toolbox's parallel
        %              cluster (configured as default) to run parallel jobs.
        %              Refer to the parallel toolbox user's manual for the
        %              description of such clusters.
        %    [m]piexec_mpi -- Uses C++ wrapped MPI libraries and mpiexec to run parallel jobs.
        %              On Windows these libraries are provided with Herbert and
        %              configured for running the parallel jobs on a working node,
        %              but a Linux machine needs these libraries installed and
        %              the cluster compiled using herbert_mex_mpi script
        %              If the jobs are expected to run on more than
        %              one node, the nodes should be configured for MPI
        %              communications (running mpiexec).
        %              Current cluster is built and tested using MPICH v3.
        %    [s]lurm_mpi -- Uses C++ wrapped MPI libraries and submits job to Slurm job queues
        %    none      -- not available. If worker can not be found on a
        %              path, no parallel cluster should be
        %              available. Parallel extensions will not work.
        parallel_cluster;

        % The configuration class describing parallel cluster, running
        % selected cluster.
        % For herbert cluster, the configuration name can only be 'local'
        % as herbert clusters runs on a single node only. A parpool
        % cluster accepts only 'default' configuration and actual configuration
        % is set up as default on distributed computing toolbox GUI.
        % 'mpi_cluster' can accept 'local' configuration for jobs, running
        % locally or any configuration, defined in
        % herbert_core/admin/mpi_cluster_configs
        % folder. The files, provided there are the files to use as input
        % for mpiexec /gmachinefile <file_name> on Windows or
        % -f <file_name> on Linux. The property picks up the file and
        % assumes that the cluster configuration, defined there is correct.
        cluster_config;

        % number of workers to deploy in parallel jobs
        accumulating_process_num;
        parallel_workers_number;

        % Number of threads to use.
        threads;

        % Number of threads to use in MPIFramework.
        par_threads;

        % Information method returning the list of the parallel clusters,
        % known to Herbert. You can not add or change a cluster
        % using this method, The cluster has to be defined and subscribed
        % via the clusters factory.
        known_clusters;

        % Information method returning list of the known configurations,
        % available to run the selected cluster.
        % For mpiexec_mpi cluster, the cluster is defined
        % by a host file used as input for mpiexec (-f option).
        % These host files should be present in admin/mpi_cluster_configs
        % folder.
        % herbert cluster runs only on a local cluster.
        % The cluster used by parpool and slurm clusters are using the default
        % configurations selected in parallel computing toolbox GUI for
        % parpool and slurm database configuration for slurm.
        known_clust_configs;

        % The folder on your working machine containing the job input and
        % output data mounted on local machine and available from the remote
        % machines.
        % Must have read/write permissions for all machines. Should be fast
        % /parallel file system on a remote machines
        %
        % If empty, assumed that the local machine filesystem is shared
        % with remote machine filesystem and have the same mounting points.
        shared_folder_on_local;

        % The place where a job data should be found on a remote worker.
        % Must have read/write permissions for all machines.
        %
        % On a MPI worker should point to the physical location equal to
        % the specified by shared_folder_on_local property
        %
        % If empty, assumed to be equal to shared_folder_on_local.
        shared_folder_on_remote;

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
        % evaluated on a remote worker equal to shared_folder_on_remote value
        working_directory;

        % Information field:
        % true, if working directory have not ever been set
        wkdir_is_default;

        % if set up, specifies the mpiexc program with full path to it,
        % used to launch parallel jobs instead of internal mpiexec
        % program, provided with Horace. Must be used when you compiled
        % cpp_communicator with external MPI libraries, so it has to be
        % launched by the mpiexec, provided with these libraries.
        %
        % Also accepts true/false values. False disables external mpiexec
        % and true tries to idenfiy mpiexec on system using "where mpiexec"
        % if this fails, external mpiexec remains empty.
        external_mpiexec;

        % Commands to be passed to slurm, can be provided as a cell array or
        % loaded from an sbatch-like file
        slurm_commands;
    end

    properties(Dependent,Hidden)
        % the property used to store is_compiled value not allowing to set
        % is_compiled porerty directly
        is_compiled_;

        % Redirect IO to host and other debug features
        debug;
    end

    properties(Constant,Access=private)
        saved_properties_list_={'worker', ...
                                'is_compiled_',...
                                'parallel_cluster', ...
                                'cluster_config', ...
                                'parallel_workers_number',...
                                'threads', ...
                                'par_threads', ...
                                'shared_folder_on_local', ...
                                'shared_folder_on_remote', ...
                                'working_directory', ...
                                'external_mpiexec', ...
                                'slurm_commands', ...
                                'debug'};
    end

    %-------------------------------------------------------------------

    properties(Access=protected)

        worker_ = 'worker_v2'
        % property, which identifies, if the worker is compiled
        is_compiled__ = false;
        % these values provide defaults for the properties above
        parallel_cluster_   = 'herbert';

        % the configuration, used as default
        cluster_config_ = 'local';

        % Default parallel workers
        parallel_workers_number_ = 2;
        % default auto threads
        threads_ = 0;
        % default auto threads
        par_threads_ = 0;

        % default remote folder is unset
        shared_folder_on_local_ ='';
        shared_folder_on_remote_ = '';

        working_directory_ ='';

        % holder to default external_mpiexec property value
        external_mpiexec_ = '';

        % slurm will run on default cluster with standard args by default
        slurm_commands_ = containers.Map('KeyType', 'char', 'ValueType', 'char');

        % Redirect IO to host
        debug_ = false;

    end

    properties(Constant)
        n_cores = feature('numcores');
    end

    methods
        function obj = parallel_config()
            % constructor
            obj=obj@config_base(mfilename('class'));
        end

        %-----------------------------------------------------------------
        % overloaded getters

        function wrkr = get.worker(obj)
            wrkr = obj.get_or_restore_field('worker');
        end

        function wrkr = get.is_compiled(obj)
            wrkr = obj.is_compiled_;
        end

        function isc = get.is_compiled_(obj)
            isc  = obj.get_or_restore_field('is_compiled_');
        end

        function obj = set.is_compiled_(obj,val)
            val = logical(val);
            config_store.instance().store_config(obj, 'is_compiled_', val);
        end

        function frmw = get.parallel_cluster(obj)

            wrkr = config_store.instance.get_value(obj,'worker');
            frmw = 'none';
            if ~isempty(which(wrkr)) || exist(wrkr, 'file')
                frmw = obj.get_or_restore_field('parallel_cluster');
            end
        end

        function debug = get.debug(obj)
            debug = get_or_restore_field(obj,'debug');
        end

        function conf = get.cluster_config(obj)
            conf = obj.get_or_restore_field('cluster_config');
        end

        function n_workers = get.parallel_workers_number(obj)
            n_workers = get_or_restore_field(obj,'parallel_workers_number');
        end

        function n_threads=get.threads(obj)
            n_threads = get_or_restore_field(obj,'threads');
            if n_threads < 1
                n_threads = obj.n_cores;
            elseif n_threads > obj.n_cores
                warning('HERBERT:parallel_config:threads', 'Number of threads (%d) might exceed computer capacity (%d)', n_threads, obj.n_cores)
            end
        end

        function n_threads=get.par_threads(obj)
            n_threads = get_or_restore_field(obj, 'par_threads');
            n_workers = get_or_restore_field(obj, 'parallel_workers_number');
            n_poss_threads = floor(obj.n_cores/n_workers);

            if n_threads < 1
                n_threads = n_poss_threads;
            elseif n_threads > n_poss_threads
                warning('HERBERT:parallel_config:par_threads', 'Number of par threads (%d) might exceed computer capacity (%d)', n_threads, n_poss_threads)
            end
        end

        function commands = get.slurm_commands(obj)
            % extra slurm commands to be passed through to
            % slurm when initialising slurm job
            commands = obj.get_or_restore_field('slurm_commands');
        end

        function folder = get.shared_folder_on_local(obj)
            folder = obj.get_or_restore_field('shared_folder_on_local');
            if isempty(folder) && MPI_State.instance().is_deployed
                folder = obj.get_or_restore_field('working_directory');
                if isempty(folder)
                    folder = tmp_dir;
                end
            end
        end

        function folder = get.shared_folder_on_remote(obj)
            folder = obj.get_or_restore_field('shared_folder_on_remote');
            if isempty(folder)
                folder = obj.shared_folder_on_local;
            end
        end

        function work_dir = get.working_directory(obj)
            is_depl = MPI_State.instance().is_deployed;
            if is_depl
                work_dir = obj.shared_folder_on_remote;
            else
                work_dir = obj.get_or_restore_field('working_directory');
            end
            if isempty(work_dir)
                work_dir = tmp_dir;
            end
        end

        function is = get.wkdir_is_default(obj)
            % returns true if working directory has not been set (points to
            % tmpdir)
            is_depl = MPI_State.instance().is_deployed;
            if is_depl
                work_dir = obj.shared_folder_on_remote;
            else
                work_dir = obj.get_or_restore_field('working_directory');
            end

            is = isempty(work_dir);

        end

        %------------------------------------------------------------------

        function frmw = get.known_clusters(obj)
            % Return list of clusters, known to Herbert
            wrkr = config_store.instance.get_value(obj,'worker');
            pkp = which(wrkr);
            if isempty(pkp)
                frmw = {'none'};
            else
                frmw = MPI_clusters_factory.instance().known_cluster_names;
            end
        end

        function clust_configs = get.known_clust_configs(obj)
            % information about clusters (cluster configurations),
            % available for the selected cluster
            fram = obj.parallel_cluster;
            if strcmpi(fram,'none')
                clust_configs = {'none'};
            else
                clust_configs = MPI_clusters_factory.instance().get_all_configs();
            end
        end

        %-----------------------------------------------------------------
        % overloaded setters
        function obj = set.worker(obj,new_wrkr)
            % Check and set new worker:
            % Input:
            % new_wrkr - the string, defining new worker function.

            obj = check_and_set_worker_(obj,new_wrkr);
        end

        function obj=set.parallel_cluster(obj,cluster_name)
            % Set up MPI cluster to use.
            %
            % Available options defined by known_clusters and are
            % defined in MPI_clusters_factory
            %
            % The cluster name (can be defined by single symbol)
            % or by a cluster number in the list of clusters
            %
            % Throws HERBERT:parallel_config:not_available
            % available on the current system.
            obj = check_and_set_cluster_(obj,cluster_name);
        end

        function obj = set.debug(obj,val)
            debug = val>0;
            config_store.instance().store_config(obj,'parallel_multifit',debug);
        end

        function obj = set.cluster_config(obj,val)
            % select one of the clusters which configuration is available
            % Throws HERBERT:parallel_config:invalid_argument if the cluster
            % configuration is invalid or not available on the current system.

            opt = obj.known_clust_configs;
            if strcmpi(opt{1},'none')
                the_config = 'none';
            else
                the_config = select_option_(opt,val);
            end

            config_store.instance().store_config(obj,'cluster_config',the_config);
        end

        function obj = set.accumulating_process_num(obj,val)
            obj.parallel_workers_number = val;
        end

        function obj = set.parallel_workers_number(obj,val)
            if val<1
                error('HERBERT:parallel_config:invalid_argument',...
                    'Number of parallel workers must be more then 1');
            end
            config_store.instance().store_config(obj,'parallel_workers_number',val);
        end

        function obj = set.threads(obj,val)
            val = max(floor(val), 0);
            config_store.instance().store_config(obj,'threads',val);
        end

        function obj = set.par_threads(obj,val)
            val = max(floor(val), 0);
            config_store.instance().store_config(obj,'par_threads',val);
        end

        function obj = set.slurm_commands(obj,val)
            if isstring(val) || ischar(val)
                val = strsplit(val)
            elseif iscellstr(val)
                ...
            else
                error('HERBERT:parallel_config:invalid_argument', ...
                      'slurm_commands must be string or cell array of strings')
            end

            if any(ismember(val, {'-J', '-n', '--ntasks-per-node', '-mpi', '--export'}))
                error('HERBERT:parallel_config:invalid_argument', ...
                      'slurm_commands cannot contain any of: -J, -n, --ntasks-per-node, -mpi or --export')
            end

            config_store.instance().store_config(obj, 'slurm_commands', val);

        end

        function obj=set.shared_folder_on_local(obj,val)
            if isempty(val)
                val = '';
            end
            if ~ischar(val)
                error('HERBERT:parallel_config:invalid_argument',...
                    ['The remote folder value should be a text string,',...
                    ' describing the location of the input/output'...
                    ' files on a remote machine'])
            end
            config_store.instance().store_config(obj,'shared_folder_on_local',val);
        end

        function obj=set.shared_folder_on_remote(obj,val)
            if isempty(val)
                val = '';
            end

            if ~ischar(val)
                error('HERBERT:parallel_config:invalid_argument',...
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
            tdr = tmp_dir;
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
                error('HERBERT:parallel_config:invalid_argument',...
                    'working directory value should be a string')
            end

            if ~isempty(val)
                if strcmp(val,tmp_dir) % avoid storing tmp dir as working directory as this is default
                    val = '';
                else
                    test_dir = fullfile(val,'horace_test_write_directory');
                    clob = onCleanup(@()rmdir(test_dir,'s'));
                    ok = mkdir(test_dir);
                    if ~ok
                        warning('HERBERT:parallel_config:invalid_argument',...
                            'working directory %s does not have write permissions. Changing it to %s directory',...
                            val,tmp_dir);
                        val = '';
                    end
                end
            end
            config_store.instance().store_config(obj,'working_directory',val);
        end

        function mpirunner = get.external_mpiexec(obj)
            mpirunner = obj.get_or_restore_field('external_mpiexec');
        end

        function obj=set.external_mpiexec(obj,val)
            if isempty(val)
                val = '';
            end
            if isnumeric(val) || islogical(val)
                val = check_and_set_external_mpiexec_(val);
            end
            if ~is_string(val)
                error('HERBERT:parallel_config:invalid_argument',...
                    'the value has to be a string specifying the program with full path to it to run mpi job')
            end
            config_store.instance().store_config(obj,'external_mpiexec',val);
        end

        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------

        function obj = load_slurm_commands_from_file(obj, filename)
            if ~is_file(filename)
                error('HERBERT:parallel_config:invalid_argument', ...
                      'File (%s) does not exist', filename);
            end
            fh = fopen(filename, 'r');
            if fh < 0
                error('HERBERT;parallel_config:io_error', ...
                      'Unknown error opening %s', filename)
            end
            data = fscanf(fh, ['#SBATCH %s'])
            fh = fclose(fh);
            if fh < 0
                error('HERBERT;parallel_config:io_error', ...
                      'Unknown error closing %s', filename)
            end


        end

        function fields = get_storage_field_names(obj)
            % helper function returns the list of the name of the structure,
            % get_data_to_store returns
            fields = obj.saved_properties_list_;
        end

        function value = get_internal_field(obj,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface
            value = obj.([field_name,'_']);
        end
    end

    methods(Static)
        function the_opt = select_option(opt,arg)
            % Select single valued option from the list of available options
            % Inputs:
            % opt -- cellarray of available options
            % arg -- either string, which uniquely define one of the options or
            %        the number, selecting the option with number.
            %        Uniquely here means that the comparison of the
            %        argument with all options available returns only
            %        one match.

            the_opt = select_option_(opt,arg);
        end

        function [keys, vals] = parse_slurm_commands(val)
        % Parse slurm commands into keys and values for building a map
        % or updating one
            if isstring(val) || ischar(val)
                val = strsplit(val, {' ', '\t', '='});
            end

            if isempty(val)
                keys = {};
                vals = {};

            elseif iscellstr(val) || isstring(val)
                keys = val(1:2:numel(val));
                vals = val(2:2:numel(val));

            elseif iscell(val) && all(cellfun(@numel, val) == 2)
                keys = cellfun(@(x) x{1}, val, 'UniformOutput', false);
                vals = cellfun(@(x) x{2}, val, 'UniformOutput', false);

                % Removed due to potential ambiguity with key-val pairs and ease of constructing a map of these anyway
                % elseif iscell(val) && numel(val) == 2
                %     keys = val{1};
                %     vals = val{2};
                %
            elseif isa(val, 'containers.Map')
                keys = val.keys();
                vals = val.values();

            else
                error('HERBERT:parallel_config:invalid_argument', ...
                      'slurm_commands must be string or cell array of strings')
            end

        end
    end
end
