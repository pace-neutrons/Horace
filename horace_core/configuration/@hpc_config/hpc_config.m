classdef hpc_config < config_base
    % Class responsible for setting related to the algorithms, which may
    % run in parallel. Defines which parallel algorithms should run in
    % parallel and what parallel options to use to achieve the best
    % performance on given machine.
    %
    % The settings optimal for given machine (or rather given machine
    % configuration) should be enabled/disabled running hpc on/hpc off
    % helper method.
    %
    % To see the list of current configuration option values:
    %   >> hpc_config
    %
    % To set values:
    %   >> hc = hpc_config();
    %   >> hc.name1=val1;
    % or
    %   >> set(hpc_config,'name1',val1,'name2',val2,...)
    %
    %
    % To fetch values:
    % >> val1 = hpc_config.name1;
    %or
    % >>[val1,val2,...]=get(hpc_config,'name1','name2',...)
    %
    %hpc_config methods are:
    %----------------------------
    % build_sqw_in_parallel - if true, use parallel framework to generate tmp files
    %                         and do other computational-expensive
    %                         tasks, benefiting from parallelization.
    % parallel_workers_number  - number of Matlab sessions (MPI workers) to
    %                           launch to run parallel code
    %
    % combine_sqw_using        - what type of sub-algorithm to use for
    %                            combining sqw/tmp files together.
    % combine_sqw_options      - the helper property providing options,
    %                            available to provide for
    %                           'combine_sqw_using' property.
    %                            Currently these options are 'matlab',
    %                            'mex_code' and 'mpi_code'
    %---
    % mex_combine_thread_mode   - various thread modes deployed when
    %                             combining sqw files using mex code.
    % mex_combine_buffer_size  - size of buffer used by mex code while
    %                            combining files per each contributing file.
    %---
    % parallel_cluster          - what parallel cluster type to use to perform
    %                             parallel  tasks. Possibilities currenlty are
    %                            'herbert', 'parpool', 'mpiexec_mpi' or
    %                            'slurm' (if appropriate clusters are
    %                             available)
    % phys_mem_available        - return real size (in bytes) of physical
    %                             memory, avaliable to use by algoritms.
    %                             Tries to allocate continuous memory at
    %                             first call and stores result for future
    %                             usage, so first call should be tried on
    %                             relatively clean system
    %
    % sort_pix_in_binary_op     - pixels are usually randomly distributed
    %                             within an image cell. To perform correct
    %                             binary operations between two sqw files
    %                             with pixel data, pixels within each image
    %                             cell have to be sorted, which is
    %                             relatively expensive operation. If you
    %                             are sure that pixels in operation come
    %                             from the same data (e.g. calculationg
    %                             foreground and background out of the same
    %                             dataset and adding them together), this
    %                             property may be set to false.
    %                             This propery is not saveable, so
    %                             returns to default each time memory is
    %                             cleared up.
    %
    %
    % Type >> hpc_config  to see the list of current configuration option values.
    %
    properties(Dependent)
        % if true, launch separate Matlab session(s) or parallel job to
        % generate tmp files
        build_sqw_in_parallel;

        % set-up algorithm, to use for combining multiple sqw(tmp) filesL
        combine_sqw_using;

        % helper read-only property, displaying possible codes to use to
        % combines sqw (combine_sqw_using) available options, namely:
        % matlab   : this mode uses initial Matlab code to combine multiple
        %            tmp files. Slowest but most reliable method, enabled by
        %            default
        % mex_code : uses multi-threaded compiled C++ mex code to combine
        %            multiple files. The mex code needs to be compiled with
        %            appropriate C++11 compiler. In case of parallel file
        %            system can be 10 times faster than Matlab mode.
        % mpi_code:  can be enabled if parallel computing toolbox is present
        %            and system supports MPI (). Performance depends on number
        %            of MPI workers and the speed of parallel file system.
        % To select one of the options above, one can provide only first
        % distinctive input for any option. (e.g. ma, me or mp)
        combine_sqw_options;

        % If mex code is used for combining tmp files various thread
        % modes can be deployed for this operation:
        % namely:
        % 0  - one thread read all tmp files and another one writes combined
        %      information into the target file
        % 1  - one thread writes combined sqw file and two threads are
        %      launched for each contributing file to read necessary information.
        %      mode 1 is combinations of modes 2 and 3.
        % Two debug modes exist to separate reading of this information:
        % 2  - a thread per contributing file is launched to read bin information
        %      when common thread for all contributing files is used to
        %      read pixel information
        % 3  - a thread is launched per contributing file to read pixel
        %      information while common thread is used to read bin
        %      information
        mex_combine_thread_mode;

        % size of buffer used by mex code while combining files per each
        % file.
        mex_combine_buffer_size;

        % Enable or disable computation of fitting in parallel.
        parallel_multifit;

        % exposes the folder used by the parallel_config for
        % storing/reading job data
        remote_folder;

        % number of workers to deploy in parallel jobs
        parallel_workers_number;

        % what parallel framework to use for parallel  tasks. Available
        % options are detailed in hpc_options. Defined in parallel_config and
        % exposed here for clarity.
        parallel_cluster;

        %----
        % immutable reference to the class, which describes the parallel
        % configuration. To change the parallel configuration, work with
        % the configuration class itself;
        parallel_config;

        % return real size (in bytes) of physical  memory, avaliable to use
        % by algoritms. Tries to allocate continuous memory at first call
        % and stores result for future usage, so first call should be tried
        % on clean system.
        phys_mem_available

        % pixels are usually randomly distributed within an image cell.
        % To perform correct binary operations between two sqw files with
        % pixel data, pixels within each image cell have to be sorted,
        % which is relatively expensive operation. If you are sure that
        % pixels in operation come  from the same data (e.g. calculating
        % foreground and background out of the same dataset and adding them
        % together), this property may be set to false.
        % The propery is not saveable in configuration files so it returns
        % to default each time memory is cleared up.
        sort_pix_in_binary_op;
        % helper read-only property, returning list of options, which
        % define hpc configuration. Set by saved_properties_list_
        hpc_options;
    end

    properties(Dependent,Hidden=true)
        % DEPRECATED properties left for old parallel interface to work
        %
        % use multi-threaded mex code to combine various sqw/tmp files together
        % deprecated property, replaced by more generic combine_sqw_using
        % property. It now is depending on it.
        use_mex_for_combine
        % if true, launch separate Matlab session(s) to generate tmp files
        accum_in_separate_process
    end

    properties(Access=protected,Hidden = true)
        build_sqw_in_parallel_ = false;
        parallel_multifit_ = false;
        combine_sqw_using_ = 'matlab';

        mex_combine_thread_mode_   = 0;
        mex_combine_buffer_size_ = 1024*64;
        sort_pix_in_binary_op_ = true;
    end

    properties(Constant,Access=private)
        % change this list if savable fields have changed or redefine
        % get_storage_field_names function below
        saved_properties_list_={...
            'build_sqw_in_parallel',...
            'combine_sqw_using',...
            'mex_combine_thread_mode',...
            'mex_combine_buffer_size',...
            'parallel_multifit'...

            };
        combine_sqw_options_ = {'matlab','mex_code','mpi_code'};
    end
    methods(Static)
        function free_memory = calc_free_memory()
            % function tries to estimate actual free memory available to
            % Horace
            %
            % Result is expressed in bytes.
            %
            free_memory = calc_free_memory_();
        end
    end

    methods
        function obj=hpc_config()
            %
            obj=obj@config_base(mfilename('class'));
            % set os-specific defaults
            if ispc
                obj.mex_combine_thread_mode_   = 0;
            elseif ismac
                ...
            elseif isunix
                obj.mex_combine_thread_mode_   = 0;
                obj.mex_combine_buffer_size_ = 64*1024;
            end
            %
            obj.mem_only_prop_list_ = {'sort_pix_in_binary_op',...
                'phys_mem_available'};
        end

        %----------------------------------------------------------------

        function mode = get.combine_sqw_using(obj)
            mode = get_or_restore_field(obj,'combine_sqw_using');
        end

        function use = get.use_mex_for_combine(obj)
            mode = get_or_restore_field(obj,'combine_sqw_using');
            use = strcmpi(mode,'mex_code');
        end

        function size= get.mex_combine_buffer_size(obj)
            size = get_or_restore_field(obj,'mex_combine_buffer_size');
        end

        function type= get.mex_combine_thread_mode(obj)
            type = get_or_restore_field(obj,'mex_combine_thread_mode');
        end

        function accum = get.accum_in_separate_process(obj)
            accum = get_or_restore_field(obj,'build_sqw_in_parallel');
        end

        function accum = get.build_sqw_in_parallel(obj)
            accum = get_or_restore_field(obj,'build_sqw_in_parallel');
        end

        function p_mf = get.parallel_multifit(obj)
            p_mf = get_or_restore_field(obj,'parallel_multifit');
        end

        function accum = get.parallel_workers_number(~)
            accum = config_store.instance.get_value('parallel_config','parallel_workers_number');
        end

        function framework = get.parallel_cluster(~)
            framework = config_store.instance.get_value('parallel_config','parallel_cluster');
        end

        function rem_f = get.remote_folder(~)
            rem_f = config_store.instance.get_value('parallel_config','remote_folder');
        end

        function rem_f = get.sort_pix_in_binary_op(obj)
            rem_f = get_or_restore_field(obj,'sort_pix_in_binary_op');
        end

        function config = get.parallel_config(~)
            config = parallel_config();
        end

        function hpco = get.hpc_options(obj)
            hpco = obj.saved_properties_list_;
        end

        function mem = get.phys_mem_available(obj)
            mem = get_phys_mem_available_(obj);
        end
        %----------------------------------------------------------------

        function obj = set.combine_sqw_using(obj,val)
            opt = obj.combine_sqw_options_;
            [ok,mess,use_matlab,use_mex,use_mpi,argi] = parse_char_options({val},opt );
            if ~isempty(argi)
                error('HORACE:hpc_config:invalid_argument',...
                    'Unrecognized option: %s. Only ''matlab'',''mex_code'' or ''mpi_code'' can be used',...
                    val);
            end

            if ~ok
                error('HORACE:hpc_config:invalid_argument',mess)
            end

            if use_matlab
                config_store.instance().store_config(obj,'combine_sqw_using','matlab');
            end

            if use_mex
                try
                    % try to run combime_sqw mex code to be sure it runs
                    ver = combine_sqw();
                    config_store.instance().store_config(obj,'combine_sqw_using','mex_code');
                catch ME
                    warning('HORACE:hpc_config:invalid_argument',...
                        'combining sqw using mex code can not be enabled. Error: %s. No changes in hpc_config',...
                        ME.message)
                end
            end

            if use_mpi
                config_store.instance().store_config(obj,'combine_sqw_using','mpi_code');
            end
        end

        function opt = get.combine_sqw_options(obj)
            opt = obj.combine_sqw_options_;
        end

        %---------

        function obj = set.use_mex_for_combine(obj,val)
            % Hidden, old option
            if val>0
                try
                    % try to run combime_sqw mex code to be sure it runs
                    ver = combine_sqw();
                    config_store.instance().store_config(obj,'combine_sqw_using','mex_code');
                catch ME
                    warning('HORACE:hpc_config:invalid_argument',...
                        [' combine_sqw.mex procedure is not availible.\n',...
                        ' Reason: %s\n.',...
                        ' Will not use mex for combining'],ME.message);
                    %config_store.instance().store_config(obj,'use_mex_for_combine',false);
                end
            else
                config_store.instance().store_config(obj,'combine_sqw_using','matlab');
            end
        end

        function obj= set.mex_combine_buffer_size(obj,val)
            if val<64
                error('HORACE:hpc_config:invalid_argument',...
                    ' mex_combine_buffer_size should be bigger then 64, and better >1024');
            end
            if val==0
                obj.use_mex_for_combine = false;
                return;
            end
            config_store.instance().store_config(obj,'mex_combine_buffer_size',val);
        end

        function obj= set.mex_combine_thread_mode(obj,val)
            if  val > 3 || val < 0
                error('HORACE:hpc_config:invalid_argument',...
                    [' mex_combine_multithreaded should be a number in the range fromn 0 to 3\n ',...
                    '  meaning:\n', ...
                    ' 0 -- minor multithreading ',...
                    ' 1 -- full multithreading',...
                    ' and two debug options:\n', ...
                    ' 2 -- only bin numbers are read by separate thread',...
                    ' 3 -- only pixels are read by separate thread']);
            end
            config_store.instance().store_config(obj,'mex_combine_thread_mode',val);
        end

        function obj = set.accum_in_separate_process(obj,val)
            obj.build_sqw_in_parallel= val;
        end

        function obj = set.parallel_multifit(obj,val)
            p_mf = val>0;
            if p_mf
                [ok,mess] = check_worker_configured(obj);
                if ~ok
                    warning('HPC_CONFIG:invalid_argument',...
                        ' Can not start accumulating in separate process as: %s',...
                        mess);
                    p_mf = false;
                end
            end
            config_store.instance().store_config(obj,'parallel_multifit',p_mf);
        end

        function obj = set.sort_pix_in_binary_op(obj,val)
            config_store.instance().store_config(obj, ...
                'sort_pix_in_binary_op',logical(val));
        end

        function obj = set.build_sqw_in_parallel(obj,val)
            accum = val>0;
            if accum
                pc = parallel_config();
                wkr = pc.worker;
                wrker_path = fileparts(which(wkr));
                if isempty(wrker_path)
                    warning(['HORACE:hpc_config:invalid_argument',...
                        'Can not start accumulating in separate process.',...
                        'Can not find worker on a data search path; ',...
                        'See: http://horace.isis.rl.ac.uk/Download_and_setup#Enabling_multi-sessions_processing ',...
                        'for the details on how to set it up']);
                    accum = false;
                end
            end
            config_store.instance().store_config(obj,'build_sqw_in_parallel',accum);

        end

        function obj = set.parallel_workers_number(obj, val)
            pf = parallel_config();
            pf.parallel_workers_number = val;
        end


        function obj = set.parallel_cluster(obj,val)
            pf = parallel_config();
            pf.parallel_cluster = val;
        end

        function obj = set.remote_folder(obj,val)
            pf = parallel_config();
            pf.remote_folder = val;
        end

        function obj = set.phys_mem_available(obj,val)
            set_phys_mem_available_(obj,val,true);
        end


        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(obj)
            % helper function returns the list of the public names of the fields,
            % which should be saved
            fields = obj.saved_properties_list_;
        end

        function value = get_default_value(obj,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface.

            if strcmp(field_name,'phys_mem_available')
                % This field does not have value as such and if it is
                % not located in config_store it is recalculated and placed
                % in store.
                value = get_phys_mem_available_(obj);
            else
                % Relies on agreement that each public
                % field has a private (default) field with name different
                % by underscore
                value = obj.([field_name,'_']);
            end
        end

    end
end
