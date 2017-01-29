classdef hor_config<config_base
    % Create the Horace configuration that sets memory options and some other defaults.
    %
    % To see the list of current configuration option values:
    %   >> hor_config
    %
    % To set values:
    %   >> hc = hor_config();
    %   >> hc.name1=val1;
    % or
    %   >> set(hor_config,'name1',val1,'name2',val2,...)
    %
    %
    % To fetch values:
    % >> val1 = hor_config.name1;
    %or
    % >>[val1,val2,...]=get(hor_config,'name1','name2',...)
    %
    %
    %hor_config methods are:
    % -----------
    %   mem_chunk_size  -   maximum length of buffer array to accumulate pixels
    %                       from an input file.
    %   threads         -   how many computational threads to use in mex files
    %   ignore_nan      -   Ignore NaN data when making cuts
    %   ignore_inf      -   Ignore Inf data when making cuts.
    %   horace_info_level -  Set verbosity of informational output.
    %   log_level         -  The synonym for the horace_info_level
    %   use_mex           -  Use mex files for time-consuming operation, if available
    %   force_mex_if_use_mex - fail if mex can not be used.
    %   delete_tmp        -  automatically delete temporary files after generating sqw files
    %
    %-----
    % Methods related to parallel file processing/combining on a cluster:
    % use_mex_for_combine     - use mex code to combine various sqw/tmp files
    %                           together
    % mex_combine_thread_mode - various thread modes deployed when
    %                           combining sqw files using mex code.
    % mex_combine_buffer_size - size of buffer used by mex code while
    %                           combining files per each contributing file.
    % accum_in_separate_process - if true, launch separate Matlab session(s) to generate tmp files
    % accumulating_process_num  - number of Matlab sessions to launch to calculate tmp files
    %
    %
    %
    % Type >> hor_config  to see the list of current configuration option values.
    %
    % $Revision$ ($Date$)
    %
    properties(Dependent)
        % Maximum number of pixels that are processed at one go during cuts
        % on usual machine with 16Gb of RAM it is 10^7  (higher value does
        % not provide obvious performance benefits) but on older machines
        % with ~4Gb it has to be reduced to 10^6
        mem_chunk_size
        % Number of threads to use in mex files. No more then number
        % of processors but value higher then 8 do not provide obvious
        % performance benefits for given mem_chink_size.
        threads
        % ignore NaN values if pixels have them.  %  (default --true)
        ignore_nan
        % ignore inf values if pixels have them. %  (default --false)
        ignore_inf
        % set horace_info_level method indicating how verbose Horace would be.
        %      The larger the value, the more information is printed.
        % See log_level for more details.
        horace_info_level
        % the same as horace_info level
        %      The larger the value, the more information is printed, e.g.:
        %  -1  No information messages printed
        %   0  Major information messages printed
        %   1  Minor information messages printed in addition
        %   2  Time of the run measured and printed as well.
        log_level
        % use mex-code for time-consuming operations
        % default -- true if mex files are compiled
        use_mex
        % testing and debugging option -- fail if mex can not be used
        % By defauld if mex file fails, program tries to use Matlab, but
        % if this option is set to true, the whole operation may fail.
        force_mex_if_use_mex
        % automatically delete temporary files after generating sqw files
        % by default its true, but you may set it to false to keep files
        % for later operations.
        delete_tmp
        % use multi-threaded mex code to combine various sqw/tmp files together
        use_mex_for_combine
        % various thread modes deployed when combining sqw files using mex code:
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
        % if true, launch separate Matlab session(s) to generate tmp files
        accum_in_separate_process
        % number of sessions to launch to calculate additional files
        accumulating_process_num
    end
    properties(Access=protected,Hidden = true)
        % private properties behind public interface
        mem_chunk_size_=10000000;
        threads_ =1;
        
        ignore_nan_ = true;
        ignore_inf_ = false;
        log_level_ = 1;
        
        use_mex_ = true;
        force_mex_if_use_mex_ = false;
        delete_tmp_ = true;
        
        use_mex_for_combine_ = false;
        %
        mex_combine_thread_mode_   = 0;
        mex_combine_buffer_size_ = 1024*64;
        
        accum_in_separate_process_ = false;
        accumulating_process_num_ = 2;
    end
    
    properties(Constant,Access=private)
        % change this list if saveable fields have changed or redefine
        % get_storage_field_names function below
        saved_properties_list_={'mem_chunk_size','threads','ignore_nan',...
            'ignore_inf', 'log_level','use_mex',...
            'force_mex_if_use_mex','delete_tmp',...
            'mex_combine_thread_mode','mex_combine_buffer_size','use_mex_for_combine',...
            'accum_in_separate_process','accumulating_process_num'}
    end
    
    methods
        function this=hor_config()
            %
            this=this@config_base(mfilename('class'));
            
            this.threads_ = find_nproc_to_use(this);
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
        
        %-----------------------------------------------------------------
        % overloaded getters
        function use = get.mem_chunk_size(this)
            use = get_or_restore_field(this,'mem_chunk_size');
        end
        function n_threads=get.threads(this)
            n_threads = get_or_restore_field(this,'threads');
        end
        function use = get.ignore_nan(this)
            use = get_or_restore_field(this,'ignore_nan');
        end
        function use = get.ignore_inf(this)
            use = get_or_restore_field(this,'ignore_inf');
        end
        function level = get.log_level(this)
            level = get_or_restore_field(this,'log_level');
        end
        function level = get.horace_info_level(this)
            % overloaded to use the same log_level real property
            level = get_or_restore_field(this,'log_level');
        end
        function use = get.use_mex(this)
            use = get_or_restore_field(this,'use_mex');
        end
        function force = get.force_mex_if_use_mex(this)
            force = get_or_restore_field(this,'force_mex_if_use_mex');
        end
        function delete = get.delete_tmp(this)
            delete = get_or_restore_field(this,'delete_tmp');
        end
        function use = get.use_mex_for_combine(this)
            use = get_or_restore_field(this,'use_mex_for_combine');
        end
        function size= get.mex_combine_buffer_size(this)
            size = get_or_restore_field(this,'mex_combine_buffer_size');
        end
        function type= get.mex_combine_thread_mode(this)
            type = get_or_restore_field(this,'mex_combine_thread_mode');
        end
        function accum = get.accum_in_separate_process(this)
            accum = get_or_restore_field(this,'accum_in_separate_process');
        end
        function accum = get.accumulating_process_num(this)
            if ~get_or_restore_field(this,'accum_in_separate_process')
                accum = 0;
            else
                accum = get_or_restore_field(this,'accumulating_process_num');
            end
        end
        
        %-----------------------------------------------------------------
        % overloaded setters
        function this = set.mem_chunk_size(this,val)
            if val<1000
                warning('HOR_CONFIG:set_mem_chunk_size',' mem chunk size should not be too small at 
least 1M is recommended');
                val = 1000;
            end
            config_store.instance().store_config(this,'mem_chunk_size',val);
        end
        function this = set.threads(this,val)
            if val<1
                warning('HOR_CONFIG:set_threads',' number ot threads can not be smaller then one. Value 
1 is used');
                val = 1;
            elseif val > 48
                warning('HOR_CONFIG:set_threads',' it is often useless to use more then 16 threads. 
Value 48 is set');
                val  = 48;
            end
            config_store.instance().store_config(this,'threads',val);
        end
        function this = set.ignore_nan(this,val)
            if val>0
                ignore = true;
            else
                ignore = false;
            end
            config_store.instance().store_config(this,'ignore_nan',ignore);
        end
        function this = set.ignore_inf(this,val)
            if val>0
                ignore = true;
            else
                ignore = false;
            end
            config_store.instance().store_config(this,'ignore_inf',ignore);
        end
        function this = set.log_level(this,val)
            if isnumeric(val)
                config_store.instance().store_config(this,'log_level',val);
            else
                error('HOR_CONFIG:set_log_level',' log level has to be numeric');
            end
        end
        function this = set.horace_info_level(this,val)
            if isnumeric(val)
                config_store.instance().store_config(this,'log_level',val);
            else
                error('HOR_CONFIG:set_horace_info_level',' horace_info_level has to be numeric');
            end
        end
        %
        function this = set.use_mex(this,val)
            if val>0
                use = true;
            else
                use = false;
            end
            if use
                % Configure mex usage
                % --------------------
                [~,n_errors,~,~,~,can_combine_with_mex]=check_horace_mex();
                if n_errors>0
                    use = false;
                    warning('HOR_CONFIG:set_use_mex',' mex files can not be initiated, Use mex set to 
false');
                end
                if ~can_combine_with_mex
                    config_store.instance().store_config(this,'use_mex_for_combine',false);
                end
            end
            config_store.instance().store_config(this,'use_mex',use);
            
        end
        %
        function this = set.force_mex_if_use_mex(this,val)
            if val>0
                use = true;
            else
                use = false;
            end
            config_store.instance().store_config(this,'force_mex_if_use_mex',use);
        end
        function this = set.delete_tmp(this,val)
            if val>0
                del = true;
            else
                del = false;
            end
            config_store.instance().store_config(this,'delete_tmp',del);
        end
        function this = set.use_mex_for_combine(this,val)
            if val>0
                try
                    ver = combine_sqw();
                    config_store.instance().store_config(this,'use_mex_for_combine',true);
                catch ME
                    warning('HOR_CONFIG:use_mex_for_combine',[' combine_sqw.mex procedure is not 
availible.\n',...
                        ' Reason: %s\n.',...
                        ' Will not use mex for combininng'],ME.message);
                    config_store.instance().store_config(this,'use_mex_for_combine',false);
                end
            else
                config_store.instance().store_config(this,'use_mex_for_combine',false);
            end
        end
        function this= set.mex_combine_buffer_size(this,val)
            if val<64
                error('HOR_CONFIG:mex_combine_buffer_size',' mex_combine_buffer_size should be bigger 
then 64, and better >1024');
            end
            if val==0
                this.use_mex_for_combine = false;
                return;
            end
            config_store.instance().store_config(this,'mex_combine_buffer_size',val);
        end
        function this= set.mex_combine_thread_mode(this,val)
            if  val>3 || val < 0
                error('HOR_CONFIG:mex_combine_thread_mode',...
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
            if val>0
                accum = true;
            else
                accum = false;
            end
            if accum
                [ok,mess] = check_worker_configured();
                if ~ok
                    warning('HOR_CONFIG:set_accum_in_separate_process',...
                        ' Can not start accumulating in separate process as: %s',...
                        mess);
                    accum = false;
                end
            end
            config_store.instance().store_config(this,'accum_in_separate_process',accum);
            
        end
        function this = set.accumulating_process_num(this,val)
            if val<1
                error('HOR_CONFIG:accumulating_process_num','Number of accumulating processes should be 
more then 1');
            else
                nproc = val;
            end
            config_store.instance().store_config(this,'accumulating_process_num',nproc);
        end
        
        
        %--------------------------------------------------------------------
        
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