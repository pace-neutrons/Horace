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
    % use_mex_for_combine       - use mex code to combine various sqw/tmp files
    %                             together
    % mex_combine_thread_mode   - various thread modes deployed when
    %                             combining sqw files using mex code.
    %---
    % parallel_framework        - what parallel framework use to perform
    %                             parallel  tasks
    % mex_combine_buffer_size   - size of buffer used by mex code while
    %                             combining files per each contributing file.
    % accum_in_separate_process - if true, use parallel framework to generate tmp files
    %                             and do other computational-expensive
    %                             tasks, benefiting from parallelization.
    % accumulating_process_num  - number of Matlab sessions to launch to calculate tmp files
    %
    %
    %
    % Type >> hpc_config  to see the list of current configuration option values.
    %
    %
    % $Revision$ ($Date$)
    %
    properties(Dependent)
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
        % what parallel framework to use for parallel  tasks. Available
        % options are: matlab, partool. Actually defined in Herbert
        parallel_framework;
        % if true, launch separate Matlab session(s) to generate tmp files
        accum_in_separate_process
        % number of sessions to launch to calculate additional files
        accumulating_process_num
        %
        remote_folder;
    end
    properties(Access=protected,Hidden = true)
        %
        use_mex_for_combine_ = false;
        %
        mex_combine_thread_mode_   = 0;
        mex_combine_buffer_size_ = 1024*64;
        
        parallel_framework_;
        accum_in_separate_process_ = false;
        accumulating_process_num_ = 2;
        current_worker_to_use_ = 'worker_v1.m'
    end
    properties(Constant,Access=private)
        % change this list if saveable fields have changed or redefine
        % get_storage_field_names function below
        saved_properties_list_={...
            'mex_combine_thread_mode','mex_combine_buffer_size',...
            'use_mex_for_combine',...
            'accum_in_separate_process','accumulating_process_num'}
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
            accum = get_or_restore_field(this,'accumulating_process_num');
        end
        function framework = get.parallel_framework(obj)
            framework = config_store.instance.get_value('parallel_config','parallel_framework');
        end
        function rem_f = get.remote_folder(obj)
            rem_f = config_store.instance.get_value('parallel_config','remote_folder');
        end
        
        %----------------------------------------------------------------
        function this = set.use_mex_for_combine(this,val)
            if val>0
                try
                    ver = combine_sqw();
                    config_store.instance().store_config(this,'use_mex_for_combine',true);
                catch ME
                    warning('HOR_CONFIG:use_mex_for_combine',...
                        [' combine_sqw.mex procedure is not availible.\n',...
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
                error('HOR_CONFIG:mex_combine_buffer_size',...
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
                [ok,mess] = check_worker_configured(this);
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
                error('HOR_CONFIG:accumulating_process_num',...
                    'Number of accumulating processes should be more then 1');
            else
                nproc = val;
            end
            config_store.instance().store_config(this,'accumulating_process_num',nproc);
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

