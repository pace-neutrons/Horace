classdef ClusterParpoolWrapper < ClusterWrapper
    % The class-wrapper for parallel computing toolbox cluster and MPI
    % job submition routinge providing the same interface as Herbert
    % custom parallel class
    %
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    %----------------------------------------------------------------------
    properties(Dependent)
        % current job identifier the class controls
        current_job;
    end
    properties(Access = protected)
        cluster_ =[];
        current_job_ = [];
        task_ = [];
    end
    
    methods
        function obj = ClusterParpoolWrapper(n_workers,mess_exchange_framework)
            % Constructor, which initiates wrapper
            %
            obj = obj@ClusterWrapper(n_workers,mess_exchange_framework);
            
            obj.cluster_  = parcluster();
            cl = obj.cluster_;
            num_labs = cl.NumWorkers;
            if num_labs < obj.n_workers
                error('PARPOOL_CLUSTER_WRAPPER:runtime_error',...
                    'job %s requested more workers (%d) then the cluster allows (%d)',...
                    me.job_id,obj.n_workers,num_labs);
            end
            cjob = createCommunicatingJob(cl,'Type','SPMD');
            if n_workers > 0
                cjob.NumWorkersRange  = obj.n_workers;
            end
            obj.current_job_  = cjob;
        end
        %
        function obj = start_job(obj,je_init_message,hWorker,task_init_mess)
            %
            % delete interactive parallel cluster if any exist
            cl = gcp('nocreate');
            if ~isempty(cl)
                delete(cl);
            end
            

            % build generic worker init string without lab parameters
            cs = obj.mess_exchange_.gen_worker_init();            
            % clear up interactive pool if exist as this method will start
            % batch job.
            % actually submit the job
            cjob = obj.current_job_;
            task = createTask(cjob,hWorker,0,{cs});
            obj.task_ = task;
            submit(cjob);
            obj = obj.init_cluster_job(je_init_message,task_init_mess);            
        end
        
        function obj=finalize_all(obj)
            obj = finalize_all@ClusterWrapper(obj);
            if ~isempty(obj.current_job_)
                delete(obj.current_job_);
                obj.current_job_ = [];
            end
            
        end
        %------------------------------------------------------------------
        function cjob = get.current_job(obj)
            cjob = obj.current_job_;
        end
    end
end

