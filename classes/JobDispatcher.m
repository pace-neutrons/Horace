classdef JobDispatcher
    % Simple multiple matlab sessions spawner
    
    
    properties(Dependent)
        % the full path to the folder where the exchange configuration is stored
        exchange_folder;
        % the jd of the job which is running
        job_id
        %
    end
    %
    properties(Constant=true)
        % the name of the folder where the configuration is stored;
        exchange_folder_name='mprogs_config';
        runninig_job_tag = 'running_job_N'
        starting_job_tag = 'starting_job_N'
    end
    properties(Access=private)
        exchange_folder_;
        job_ID_ = 0;
        running_jobs_={};
    end
    methods(Static)
        function job_struct = job_structure(id,stat_file)
            job_struct = struct('job_id',id,'job_status_file',stat_file,...
                'waiting_count',0,'is_running',false,'is_starting',false,...
                'faliled',false);
        end
        function params = restore_param(is_class,par_string)
            % function restores job parameters from job string
            % representation
            %
            % should be overloaded if the class
            % used as job input is not a rundata class
            %
            par_string = strrep(par_string,'x',' ');
            if is_class
                params  = rundata.from_string(par_string);
            else
                len = numel(par_string)/3;
                sa = reshape(par_string,len,3);
                iarr = uint8(str2num(sa));
                
                params  =  hlp_deserialize(iarr);
            end
            
        end
    end
    
    methods
        function jd = JobDispatcher()
            % Initialise folder path
            jd.exchange_folder_ = make_config_folder(JobDispatcher.exchange_folder_name);
        end
        function job_status_file = get_job_stat_file(obj,id,state)
            if strcmp(state,'start')
                job_status_file  = fullfile(obj.exchange_folder,sprintf('%s%d.txt',JobDispatcher.starting_job_tag,id));
            else
                job_status_file  = fullfile(obj.exchange_folder,sprintf('%s%d.txt',JobDispatcher.runninig_job_tag,id));
            end
        end
        
        
        %
        function this=send_jobs(this,job_param_list)
            % send range of jobs to run
            %
            n_jobs = numel(job_param_list);
            this.running_jobs_=cell(n_jobs,1);
            program = 'c:\\Programming\\Matlab2015b64\\bin\\matlab.exe';
            
            for id=1:n_jobs
                if isstruct(job_param_list{id})
                    v = hlp_serialize(job_param_list{id});
                    str_repr =num2str(v);
                    str_repr = reshape(str_repr,1,numel(str_repr));
                    is_class = false;
                else
                    if any(strcmp(methods(job_param_list{id}), 'to_string'))
                        str_repr = job_param_list{id}.to_string();
                        is_class = true;
                    else
                        warning('JOB_DISPATCHER:send_job','job N %d can not be serialized, skipping it',id);
                        continue;
                    end
                end
                ars = strrep(str_repr,' ','x');
                job_status_f = this.get_job_stat_file(id,'start');
                f = fopen(job_status_f,'w');
                fwrite(f,'starting','char');
                fclose(f);
                this.running_jobs_{id} = JobDispatcher.job_structure(id,job_status_f);
                this.running_jobs_{id}.is_starting = true;
                
                job_string = sprintf('!%s -nojvm -nosplash -r worker(%d,%d,''%s'');exit; & exit',...
                    program,id,is_class,ars);
                eval(job_string);
            end
            
            count = 0;
            fail_limit = 10;
            [completed,this]=this.check_jobs_completed(count,fail_limit);
            while(~completed)
                pause(10);
                [completed,this]=this.check_jobs_completed(count,fail_limit);
                count = cound+1;
            end
        end
        
        function [completed,this]= check_jobs_completed(this,count,fail_limit)
            
            n_jobs = numel(this.running_jobs_);
            all_failed = true;
            all_finished=true;
            for id=1:n_jobs
                if isempty(this.running_jobs_{id})
                    continue;
                end
                job = this.running_jobs_{id};
                if job.faliled
                    continue;
                end
                all_failed=false;
                %
                if job.is_running
                    if ~(exist(job.job_status_file,'file')==2)
                        job.is_running=false;
                    else
                        if ~job.is_starting
                            all_finished = false;
                        end
                    end
                end
                %
                if job.is_starting
                    if exist(job.job_status_file,'file')==2
                        job.waiting_count = job.waiting_count+1;
                        if job.waiting_count > fail_limit
                            job.faliled = true;
                        end
                    else
                        running_stat_file = get_job_stat_file(this,job.job_id,'run');
                        if exist(running_stat_file ,'file')==2
                            job.waiting_count = 0;
                            job.job_status_file = running_stat_file;
                            job.is_starting = false;
                            job.is_runnint = true;
                        end
                    end
                end
                %
                this.running_jobs_{id}=job;
            end
            completed = all_finished||all_failed;
        end
        
        function this=init_job(this,id)
            this.job_ID_ = id;
            running_stat_file  = this.get_job_stat_file(id,'run');
            starting_stat_file = this.get_job_stat_file(id,'start');
            if exist(starting_stat_file,'file')==2
                delete(starting_stat_file)
            end
            f = fopen(running_stat_file  ,'w');
            fwrite(f,'running','char');
            fclose(f);
        end
        
        function this=finish_job(this)
            running_stat_file  = this.get_job_stat_file(this.job_id,'run');
            
            if exist(running_stat_file ,'file')==2
                delete(running_stat_file )
            end
            this.job_ID_=0;
        end
        
        function do_job(this,is_class,params)
            % abstract method which have particular implementation for
            % testing purposes only
            % the particular worker should overload this method
            job_par = JobDispatcher.restore_param(is_class,params);
            
            job_num = this.job_id();
            filename = sprintf(job_par.filename_template,job_num);
            file = fullfile(job_par.filepath,filename);
            f=fopen(file,'w');
            fwrite(f,['file: ',file],'char');
            fclose(f);
            pause(3);
            
        end
        
        function id = get.job_id(this)
            id = this.job_ID_;
        end
        function path=get.exchange_folder(this)
            path=this.exchange_folder_;
        end
        
    end
    
    
end

