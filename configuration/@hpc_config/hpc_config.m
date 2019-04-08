classdef hpc_config < config_base
    % Class responsible for high performance computing setting
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
    %                             and do other computational-expensive
    %                             tasks, benefiting from parallelization.
    % parallel_workers_number  - number of Matlab sessions (MPI workers) to launch to run parallel code
    %
    %
    % combine_sqw_using        - what type of sub-algorithm to use for combining sqw/tmp files
    %                            together. Options are 'matlab', 'mex_code' and 'mpi_code'
    % mex_combine_thread_mode   - various thread modes deployed when
    %                             combining sqw files using mex code.
    %---
    % parallel_framework        - what parallel framework use to perform
    %                             parallel  tasks. Possibilities are 'herbert' or 'parpool'
    % mex_combine_buffer_size   - size of buffer used by mex code while
    %                             combining files per each contributing file.
    %
    %
    % Type >> hpc_config  to see the list of current configuration option values.
    %
    %
    % $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
    %
    properties(Dependent)
        % if true, launch separate Matlab session(s) or parallel job to
        % generate tmp files
        build_sqw_in_parallel;
        % number of workers to deploy in parallel jobs
        parallel_workers_number;
        %
        % property describes the algorithm, used to combine multiple
        % sqw(tmp) files, namely:
        % matlab   : this mode uses initial Matlab code to combine multiple
        %            tmp files. Slowest but most reliable method, enabled by
        %            default
        % mex_code : uses multi-threaded compiled C++ mex code to combine
        %            multiple files. The mex code needs to be compiled with
        %            appropriate C++11 compiler. In case of parallel file
        %            system can be 10 times faster than Matlab mode.
        % mpi_code : can be enabled if parallel computing toolbox is present
        %            and system supports MPI (). Performance depends on number
        %            of MPI workers and the speed of parallel file system.
        % To select one of the options above, one can provide only first
        % distinctive input for any option. (e.g. ma, me or mp)
        combine_sqw_using
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
        mex_combine_thread_mode
        % size of buffer used by mex code while combining files per each
        % file.
        mex_combine_buffer_size
        %
        remote_folder;
        % what parallel framework to use for parallel  tasks. Available
        % options are: matlab, partool. Actually defined in parqallel_config and 
        % exposed here for clarity.
        parallel_framework;
        % immutable reference to the class, which describes the parallel
        % configuration. To change the parallel configuration, work with
        % this configuration class itself;
        parallel_configuration
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
        % number of sessions to launch to calculate additional files
        accumulating_process_num
    end
    properties(Access=protected,Hidden = true)
        build_sqw_in_parallel_ = false;
        parallel_workers_number_ = 2;
        %
        combine_sqw_using_ = 'matlab';
        %
        mex_combine_thread_mode_   = 0;
        mex_combine_buffer_size_ = 1024*64;
        
        current_worker_to_use_ = 'worker_v1.m'
    end
    properties(Constant,Access=private)
        % change this list if savable fields have changed or redefine
        % get_storage_field_names function below
        saved_properties_list_={...
            'build_sqw_in_parallel','parallel_workers_number',...
            'combine_sqw_using',...
            'mex_combine_thread_mode','mex_combine_buffer_size',...
            }
    end
    
    methods
        function this=hpc_config()
            %
            this=this@config_base(mfilename('class'));
            % set os-specific defaults
            if ispc
                this.mex_combine_thread_mode_   = 0;
            elseif isunix
                if ~ismac
                    this.mex_combine_thread_mode_   = 0;
                    this.mex_combine_buffer_size_ = 64*1024;
                end
            end
        end
        %----------------------------------------------------------------
        function mode = get.combine_sqw_using(obj)
            mode = get_or_restore_field(obj,'combine_sqw_using');
        end
        %
        function use = get.use_mex_for_combine(obj)
            mode = get_or_restore_field(obj,'combine_sqw_using');
            if strcmpi(mode,'mex_code')
                use = true;
            else
                use = false;
            end
        end
        function size= get.mex_combine_buffer_size(this)
            size = get_or_restore_field(this,'mex_combine_buffer_size');
        end
        function type= get.mex_combine_thread_mode(this)
            type = get_or_restore_field(this,'mex_combine_thread_mode');
        end
        function accum = get.accum_in_separate_process(this)
            accum = get_or_restore_field(this,'build_sqw_in_parallel');
        end
        function accum = get.accumulating_process_num(this)
            accum = get_or_restore_field(this,'parallel_workers_number');
        end
        function accum = get.build_sqw_in_parallel(this)
            accum = get_or_restore_field(this,'build_sqw_in_parallel');
        end
        function accum = get.parallel_workers_number(this)
            accum = get_or_restore_field(this,'parallel_workers_number');
        end
        function framework = get.parallel_framework(obj)
            framework = config_store.instance.get_value('parallel_config','parallel_framework');
        end
        function rem_f = get.remote_folder(obj)
            rem_f = config_store.instance.get_value('parallel_config','remote_folder');
        end
        function config = get.parallel_configuration(obj)
            config = parallel_config();
        end
        %----------------------------------------------------------------
        function this = set.combine_sqw_using(this,val)
            options = {'matlab','mex_code','mpi_code'};
            [ok,mess,use_matlab,use_mex,use_mpi,argi] = parse_char_options({val},options);
            if ~isempty(argi)
                error('HPC_CONFIG:invalid_argument',...
                    'Unrecognized option: %s. Only ''matlab'',''mex_code'' or ''mpi_code'' can be used',...
                    val);
            end
            if ~ok
                error('HPC_CONFIG:invalid_argument',mess)
            end
            if use_matlab
                config_store.instance().store_config(this,'combine_sqw_using','matlab');
            end
            if use_mex
                try
                    % try to run combime_sqw mex code to be sure it runs
                    ver = combine_sqw();
                    config_store.instance().store_config(this,'combine_sqw_using','mex_code');
                catch ME
                    warning('HPC_CONFIG:invalid_argument',...
                        'combining sqw using mex code can not be enabled. Error: %s. No changes in hpc_config',...
                        ME.message)
                end
            end
            if use_mpi
                [valid,errmsg] = license('checkout','Distrib_Computing_Toolbox');
                if ~valid
                    warning('HPC_CONFIG:invalid_argument',...
                        'can not enable Parallel Computing Toolbox. Error: %s. Ho changes in hpc_config',...
                        errmsg)
                else
                    config_store.instance().store_config(this,'combine_sqw_using','mpi_code');
                end
            end
        end
        
        function this = set.use_mex_for_combine(this,val)
            if val>0
                try
                    % try to run combime_sqw mex code to be sure it runs
                    ver = combine_sqw();
                    config_store.instance().store_config(this,'combine_sqw_using','mex_code');
                catch ME
                    warning('HPC_CONFIG:invalid_argument',...
                        [' combine_sqw.mex procedure is not availible.\n',...
                        ' Reason: %s\n.',...
                        ' Will not use mex for combining'],ME.message);
                    %config_store.instance().store_config(this,'use_mex_for_combine',false);
                end
            else
                config_store.instance().store_config(this,'combine_sqw_using','matlab');
            end
        end
        function this= set.mex_combine_buffer_size(this,val)
            if val<64
                error('HPC_CONFIG:invalid_argument',...
                    ' mex_combine_buffer_size should be bigger then 64, and better >1024');
            end
            if val==0
                this.use_mex_for_combine = false;
                return;
            end
            config_store.instance().store_config(this,'mex_combine_buffer_size',val);
        end
        function this= set.mex_combine_thread_mode(this,val)
            if  val>3 || val < 0
                error('HPC_CONFIG:invalid_argument',...
                    [' mex_combine_multithreaded should be a number in the range fromn 0 to 3\n ',...
                    '  meaning:\n', ...
                    ' 0 -- minor multitheading ',...
                    ' 1 -- full multitrheading',...
                    ' and two debug options:\n', ...
                    ' 2 -- only bin numbers are read by separate thread',...
                    ' 3 -- only pixels are read by separate thread']);
            end
            config_store.instance().store_config(this,'mex_combine_thread_mode',val);
        end
        
        function this = set.accum_in_separate_process(this,val)
            this.build_sqw_in_parallel= val;
        end
        %
        function this = set.build_sqw_in_parallel(this,val)
            if val>0
                accum = true;
            else
                accum = false;
            end
            if accum
                [ok,mess] = check_worker_configured(this);
                if ~ok
                    warning('HPC_CONFIG:invalid_argument',...
                        ' Can not start accumulating in separate process as: %s',...
                        mess);
                    accum = false;
                end
            end
            config_store.instance().store_config(this,'build_sqw_in_parallel',accum);
            
        end
        function this = set.accumulating_process_num(this,val)
            this.parallel_workers_number = val;
        end
        function this = set.parallel_workers_number(this,val)
            if val<1
                error('HPC_CONFIG:invalid_argument',...
                    'Number of parallel workers should be more then 1');
            else
                nproc = val;
            end
            config_store.instance().store_config(this,'parallel_workers_number',nproc);
        end
        
        function obj = set.parallel_framework(obj,val)
            pf = parallel_config;
            pf.parallel_framework = val;
        end
        function obj = set.remote_folder(obj,val)
            pf = parallel_config;
            pf.remote_folder = val;
        end
        
        %------------------------------------------------------------------
        % ABSTACT INTERFACE DEFINED
        %------------------------------------------------------------------
        function fields = get_storage_field_names(this)
            % helper function returns the list of the public names of the fields,
            % which should be saved
            fields = this.saved_properties_list_;
        end
        %
        function value = get_internal_field(this,field_name)
            % method gets internal field value bypassing standard get/set
            % methods interface.
            % Relies on assumption, that each public
            % field has a private field with name different by underscore
            value = this.([field_name,'_']);
        end
        
        
    end
end

