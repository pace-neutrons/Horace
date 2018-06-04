classdef test_job_dispatcher_parpool< MPI_Test_Common
    % Test running using the parpool job dispatcher.
    %
    % $Revision: 696 $ ($Date: 2018-02-06 13:59:38 +0000 (Tue, 06 Feb 2018) $)
    %
    
    properties
        skip_tests  = false;
    end
    methods
        %
        function this=test_job_dispatcher_parpool(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_parpool';
            end
            this = this@MPI_Test_Common(name);
        end
        %
        function test_job_with_logs_worker(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL1_nf2.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL1_nf3.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher('test_parpool_1worker');
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,3,true,1,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),1);
            assertEqual(outputs{1},'Job 1 generated 3 files');
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        %
        function test_job_with_logs_2workers(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL2_nf1.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL2_nf2.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher('test_parpool_2workers');
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,3,true,2,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),2);
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 2 files');
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        %
        function test_job_with_logs_3workers(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL2_nf1.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL3_nf1.txt');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher('test_parpool_3workers');
            
            [outputs,n_failed]=jd.start_job('JETester',common_param,3,true,3,false,1);
            
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),3);
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 1 files');
            assertEqual(outputs{3},'Job 3 generated 1 files');
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        
        function test_job_fail_restart(this,varargin)
            if this.skip_tests
                return;
            end
            if nargin>1
                this.setUp();
                clob0 = onCleanup(@()tearDown(this));
            end
            
            % overloaded to empty test -- nothing new for this JD
            % JETester specific control parameters
            common_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt',...
                'fail_for_labsN',2);
            
            file1= fullfile(this.working_dir,'test_jobDispatcherL1_nf1.txt');
            file2= fullfile(this.working_dir,'test_jobDispatcherL2_nf1.txt');
            file3= fullfile(this.working_dir,'test_jobDispatcherL3_nf1.txt');
            file3a= fullfile(this.working_dir,'test_jobDispatcherL3_nf2.txt');
            
            files = {file1,file3,file3a};
            co = onCleanup(@()(delete(files{:})));
            
            jd = JobDispatcher('test_job_fail_restart');
            
            [outputs,n_failed,~,jd]=jd.start_job('JETester',common_param,4,true,3,true,1);
            
            assertEqual(n_failed,1);
            assertEqual(numel(outputs),3);
            assertTrue(isa(outputs{2},'MException'));
            %assertEqual(outputs{1},'Job 1 generated 1 files');
            %assertEqual(outputs{2},'Job 2 generated 1 files'); % this one
            %fails
            %assertEqual(outputs{3},'Job 3 generated 1 files');
            assertTrue(exist(file1,'file')==2);
            assertFalse(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            assertTrue(exist(file3a,'file')==2);
            co = onCleanup(@()(delete(file3,file3a)));
            
            common_param.fail_for_labsN  =1:2;
            [outputs,n_failed,~,jd]=jd.restart_job('JETester',common_param,4,true,true,1);
            
            assertEqual(n_failed,2);
            assertEqual(numel(outputs),3);
            assertTrue(isa(outputs{1},'MException'));                        
            assertTrue(isa(outputs{2},'MException'));            
            assertFalse(exist(file1,'file')==2);
            assertFalse(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            assertTrue(exist(file3a,'file')==2);
            
            common_param = rmfield(common_param,'fail_for_labsN');
            files = {file1,file2,file3};
            co = onCleanup(@()(delete(files{:})));
            
            [outputs,n_failed]=jd.restart_job('JETester',common_param,3,true,false,1);
            assertEqual(n_failed,0);
            assertEqual(numel(outputs),3);
            
            assertEqual(outputs{1},'Job 1 generated 1 files');
            assertEqual(outputs{2},'Job 2 generated 1 files');
            assertEqual(outputs{3},'Job 3 generated 1 files');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file2,'file')==2);
            assertTrue(exist(file3,'file')==2);
            
        end
        function test_finish_2tasks_reduce_messages(obj,varargin)
            if obj.skip_tests
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            serverfbMPI  = MessagesFilebased('test_finish_2tasks_reduce_mess');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % generate 3 controls to have 3 filebased MPI pseudoworkers
            css1= serverfbMPI.gen_worker_init();
            
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 4
                return;
            end
            num_labs = 4;
            pl = gcp('nocreate'); % Get the current parallel pool
            if isempty(pl) || pl.NumWorkers ~=num_labs
                delete(pl)
                pl = parpool(cl,num_labs);
            end
            
            spmd
                ok = finish_task_tester(css1);
            end
            
            
            assertEqual(numel(ok),num_labs);
            all_ok = arrayfun(@(x)(x{1}),ok,'UniformOutput',true);
            assertTrue(all(all_ok));
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            
        end
        
        
    end
end

