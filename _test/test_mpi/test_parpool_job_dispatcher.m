classdef test_parpool_job_dispatcher< test_job_dispatcher
    % Test running using the parpool job dispatcher. 
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
    end
    methods
        %
        function this=test_parpool_job_dispatcher(name)
            if ~exist('name','var')
                name = 'test_parpool_job_dispatcher';
            end
            this = this@test_job_dispatcher(name);
            pc = parallel_config;
            current_pool = pc.parallel_framework;
            try
                pc.parallel_framework = 'parpool';
            catch
                this.skip_tests = true;
            end
            pc.parallel_framework = current_pool;
            this.test_dispatcher = 'parpool';
        end
        %
        function test_job_with_logs_worker(this)
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            job_contr = struct('loop_param',[],'n_steps',3,...
                'return_results',false);
            job_contr.loop_param =[job_param,job_param,job_param];
            
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL1_nf3.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            job_par = job_contr;
            jd = JobDispatcher();
            
            [n_failed,outputs]=jd.start_tasks('JETester',job_par,1,1);
            
            assertEqual(n_failed,0);
            assertTrue(isempty(outputs{1}));
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        %
        function test_job_controls_no_running(this)
            % overloaded to empty test -- nothing new for this JD
        end
        %
        function test_split_job_list(this)
            % overloaded to empty test -- nothing new for this JD
        end
   
        
        
    end
end

