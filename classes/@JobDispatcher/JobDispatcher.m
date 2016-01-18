classdef JobDispatcher
    % Simple multiple matlab sessions spawner
    %
    % Similar to parfor bud does not need parallel toolbox and start
    % separate matlab sessions to do the job
    %
    % Works in conjuction with worker function from admin folder,
    % The worker has to be placed on matlab search path
    % defined before herbert is initiated
    %
    %
    % $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
    %
    %
    properties(Dependent)
        % the full path to the folder where the exchange configuration is stored
        exchange_folder;
        % the jd of the the job which is running
        job_id
        % method returns a qualified name of a program to run (e.g. Matlab
        % with all attributes necessary to start it (e.g. path if the program
        % is not on the path)
        worker_prog_name;
        % the name of a service file, which indicates that job is running
        running_job_file_name;
    end
    %
    properties(Constant=true)
        % the name of the folder where the configuration is stored;
        exchange_folder_name='mprogs_config';
        starting_job_tag = 'starting_job_N'
        runninig_job_tag = 'running_job_N'
        completed_job_tag= 'finished_job_N'
    end
    
    properties(Constant=true,Access=private)
        start_tag_='starting'
        run_tag_ = 'running'
        end_tag_ = 'ended'
    end
    %
    properties(Access=private)
        exchange_folder_;
        job_ID_ = 0;
        running_jobs_={};
        fail_limit_ = 30; % number of times to try for changes in job status file until
        % deciding the job have failed
    end
    methods(Static,Access=private)
        %
        function job_struct = job_structure(id,stat_file)
            job_struct = struct('job_id',id,'job_status_file',stat_file,...
                'waiting_count',0,'is_running',false,'is_starting',false,...
                'faliled',false);
        end
        %
        function params = restore_param(class_name,par_string)
            % function restores job parameters from job string
            % representation
            %
            % should be overloaded if the class
            % used as job input is not a rundata class
            %
            par_string = strrep(par_string,'x',' ');
            if ~isempty(class_name)
                instance = feval(class_name);
                params  = instance.from_string(par_string);
            else
                len = numel(par_string)/3;
                sa = reshape(par_string,len,3);
                iarr = uint8(str2num(sa));
                
                params  =  hlp_deserialize(iarr);
            end
        end
        %
        function [par,class_name,mess] = make_job_par_string(param)
            % convert job parameters structure or class into job
            % parameter's string
            %
            % (e.g. serialize job parameters in a way, to be able to
            % transter it to other Matlab session
            %
            mess = '';
            if isstruct(param)
                v = hlp_serialize(param);
                str_repr =num2str(v);
                str_repr = reshape(str_repr,1,numel(str_repr));
                class_name = '';
            else
                if any(strcmp(methods(param), 'to_string'))
                    str_repr = param.to_string();
                    class_name = class(param);
                else
                    par = '';
                    mess = 'input parameters can not be converted to string';
                    return
                end
            end
            par = strrep(str_repr,' ','x');
        end
        
    end
    
    methods
        function jd = JobDispatcher()
            % Initialise folder path
            jd.exchange_folder_ = make_config_folder(JobDispatcher.exchange_folder_name);
        end
        %
        function n_failed=send_jobs(this,job_param_list,varargin)
            % send range of jobs to execute by external program
            %
            % Usage:
            % n_failed=send_jobs(this,job_param_list,[number_of_workers,[job_query_time]])
            %Where:
            % job_param_list -- cellarray of structures containing the
            %                   parameters of the jobs to run
            % number_of_workers -- if present, number of matlab sessions to
            %                   start to deal with the jobs. By default,
            %                   the number of sessions is equal to number
            %                   of jobs
            % job_query_time    -- if present -- time interval to check if
            %                   jobs are completed. By default, check every
            %                   4 seconds
            %
            % Returns
            % n_failed  -- number of jobs that have failed.
            %
            %
            n_failed=send_jobs_to_workers_(this,job_param_list,varargin{:});
        end
        
        
        function this=init_job(this,id)
            % set up tag, indicating that the job have started
            this=do_init_job_(this,id);
        end
        function this=finish_job(this)
            % set up tag, indicating that the job have finished
            this = do_finish_job_(this);
        end
        
        function do_job(this,class_name,varargin)
            % abstract method which have particular implementation for
            % testing purposes only
            %
            % the particular JobDispatcher should overload this method
            % keeping the same meaning for the interface
            %
            % this particular implementation writes files according to template,
            % provided in test_job_dispatcher.m file
            n_jobs = numel(varargin);
            job_num = this.job_id();
            for ji = 1:n_jobs
                job_par = JobDispatcher.restore_param(class_name,varargin{ji});
                
                filename = sprintf(job_par.filename_template,job_num,ji);
                file = fullfile(job_par.filepath,filename);
                f=fopen(file,'w');
                fwrite(f,['file: ',file],'char');
                fclose(f);
            end
            pause(1);
            
        end
        %-------------------------------------------------------------------
        function id = get.job_id(this)
            % get number (job id) of current running job
            id = this.job_ID_;
        end
        %
        function path=get.exchange_folder(this)
            % the name of the folder to store service files, indicating the
            % job progress
            path=this.exchange_folder_;
        end
        %
        function prog_name = get.worker_prog_name(this)
            % get fully qualified program name to start job with
            %
            % Here we expect to start Matlab
            % Fully qualified means name with full path, whcih allows to
            % start program which is not on system path.
            %
            prog_path  = found_matlab_path();
            if isempty(prog_path)
                error('JOBDISPATCHER:invlid_settings','Can not find matlab');
            end
            if ispc
                prog_name = fullfile(prog_path,'matlab.exe');
            else
                prog_name = fullfile(prog_path,'matlab');
            end
            %prog_name = 'c:\\Programming\\Matlab2015b64\\bin\\matlab.exe';
        end
        %
        function fname = get.running_job_file_name(this)
            % get the file name used to indicate that the job is
            % running
            fname  = get_job_stat_file_(this,this.job_id,this.run_tag_);
        end
        
    end
    methods(Access=private)
        [completed,n_failed,this]= check_jobs_completed_(this,count);
        
        function job_status_file = get_job_stat_file_(obj,id,state)
            % generate job status file name and path
            if strcmp(state,obj.start_tag_)
                job_status_file  = fullfile(obj.exchange_folder,sprintf('%s%d.txt',JobDispatcher.starting_job_tag,id));
            elseif strcmp(state,obj.run_tag_)
                job_status_file  = fullfile(obj.exchange_folder,sprintf('%s%d.txt',JobDispatcher.runninig_job_tag,id));
            else
                job_status_file  = fullfile(obj.exchange_folder,sprintf('%s%d.txt',JobDispatcher.completed_job_tag,id));
            end
        end
        
        
    end
    
    
end

