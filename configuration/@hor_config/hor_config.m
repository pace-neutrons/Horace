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
    % Fields are:
    % -----------
    %   mem_chunk_size      Maximum number of pixels that are processed at one go during cuts
    %   threads             Number of threads to use in mex files
    %   ignore_nan          Ignore NaN data when making cuts
    %   ignore_inf          Ignore Inf data when making cuts
    %   horace_info_level   Set verbosity of informational output
    %                           -1  No information messages printed
    %                            0  Major information messages printed
    %                            1  Minor information messages printed in addition
    %                            2  Time of the run measured and printed as well. 
    %                                   :
    %                       The larger the value, the more information is printed
    %   use_mex             Use mex files for time-consuming operation, if available
    %   force_mex_if_use_mex % testing and debugging option -- fail if mex can not be used   
    %
    % Type >> hor_config  to see the list of current configuration option values.
    %
    % $Revision$ ($Date$)
    %
    properties(Dependent)
        mem_chunk_size    % maximum length of buffer array in which to accumulate points from the input file
        threads           % how many computational threads to use in mex files and by Matlab
        ignore_nan        % ignore NaN values
        ignore_inf        % ignore inf values;
        horace_info_level % set horace_info_level method
        log_level         % the same as horace_info level
        use_mex           % use mex-code for time-consuming operations
        force_mex_if_use_mex % testing and debugging option -- fail if mex can not be used
        delete_tmp        % automatically delete temporary files after generating sqw files
        % These three method added to deal with RHEL 6 & 7 OMP error, when
        % OMP job runs extreamly slow after 
        avrg_gensqw_time   % the average time to run gensqw omp job set this value to enable OMP thread managment
                           % the value should bee bit more then
                           % 3*time_to_complete_the_job single threaded
        call_counter       % counter used in measuring the OMP job performance fall if any
        estimate_processing_time  % boolean which is true if avrg_gensqw_time is set
                                  %and OMP thread managment should be enabled
        
    end
    properties(Access=protected)
        % private properties behind public interface
        mem_chunk_size_=10000000;
        threads_ =1;
        ignore_nan_ = true;
        ignore_inf_ = false;
        log_level_ = 1;
        use_mex_ = true;
        force_mex_if_use_mex_ = false;
        delete_tmp_ = true;
        avrg_gensqw_time_ = 0;
        call_counter_ = 0;
    end
    
    properties(Constant,Access=private)
        saved_properties_list_={'mem_chunk_size','threads','ignore_nan',...
            'ignore_inf', 'log_level','use_mex',...
            'force_mex_if_use_mex','delete_tmp',...
            'avrg_gensqw_time','call_counter'}
    end
    
    methods
        function this=hor_config()
            %
            this=this@config_base(mfilename('class'));
            
            this.threads_ = find_nproc_to_use(this);
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
        
        %-----------------------------------------------------------------
        % overloaded setters
        function this = set.mem_chunk_size(this,val)
            if val<1000
                warning('HOR_CONFIG:set_mem_chunk_size',' mem chunk size should not be too small at least 1M is recommended');
                val = 1000;
            end
            config_store.instance().store_config(this,'mem_chunk_size',val);
        end
        function this = set.threads(this,val)
            if val<1
                warning('HOR_CONFIG:set_threads',' number ot threads can not be smaller then one. Value 1 is used');
                val = 1;
            elseif val > 48
                warning('HOR_CONFIG:set_threads',' it is often useless to use more then 16 threads. Value 48 is set');
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
                [dummy,n_errors]=check_horace_mex();
                if n_errors>0
                    use = false;
                    warning('HOR_CONFIG:set_use_mex',' mex files can not be initiated; use_mex set to false');
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
        %--------------------------------------------------------------------
        function this = set.avrg_gensqw_time(this,val)
            if val>0
                config_store.instance().store_config(this,'avrg_gensqw_time',val);
            else
                config_store.instance().store_config(this,'avrg_gensqw_time',0);
            end
            
        end
        
        function time = get.avrg_gensqw_time(this)
            time = get_or_restore_field(this,'avrg_gensqw_time');
        end
        
        function increase_threads = check_time_acceptable(this,time)
            % method comapres etalon time, defined within the class
            % with the time provided as input
            % and returns suggestions on increase/decrease number of
            % threads executing the job evaluated
            %
            % Usage:
            % nthreads=hor_config_instance.check_time_acceptable(time)
            %          where time is the time clacked to do the job. 
            %Returns:
            % 0    -- if time provided is less then 4 etalon times
            % -1   -- if the time is higher then 4 etalon times for the first time
            % 1    -- if -1 was issued before and the time was smaller then 3
            %         etalon times three times in a row

            increase_threads = 0;
            etalon = this.avrg_gensqw_time;
            if this.call_counter~=0
                if time<=3*etalon % normal speed of calculating data wtih one omp thread. 
                    this.call_counter_incr();
                    if this.call_counter >= 4
                        increase_threads = 1;
                        this.call_counter = 0;
                    end
                else 
                    % increase number of threads only if the execution time
                    % was low three times in a row. Drop call counter to
                    % inital value otherwise. 
                    if this.call_counter>1
                        this.call_counter=1;
                    end
                end
            else
                if time>4*etalon
                    this.call_counter_incr();
                    increase_threads = -1;
                end
            end
            
        end
        
        function this = set.call_counter(this,val)
            config_store.instance().store_config(this,'call_counter',val);
        end
        function this = call_counter_incr(this)
            count = get_or_restore_field(this,'call_counter');
            count=count+1;
            config_store.instance().store_config(this,'call_counter',count);
        end       
        function count = get.call_counter(this)
            count = get_or_restore_field(this,'call_counter');
        end
        %
        %function this = set.estimate_processing_time(this,val)
        %end
        
        function est = get.estimate_processing_time(this)
            time = get_or_restore_field(this,'avrg_gensqw_time');
            if time>0
                est=true;
            else
                est = false;
            end
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
            % methods interface
            value = this.([field_name,'_']);
        end
        
    end
end