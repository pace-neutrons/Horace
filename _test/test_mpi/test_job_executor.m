classdef test_job_executor< MPI_Test_Common
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
    %
    
    properties
        current_config_folder;
        worker_h = @worker_v1;
    end
    methods
        %
        function this=test_job_executor(name)
            if ~exist('name','var')
                name = 'test_job_executor';
            end
            % testing this on file-based framework only
            this = this@MPI_Test_Common(name,'herbert');
            this.working_dir = tempdir;
        end
        function test_worker_fails(obj)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            % build jobs data
            common_job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt',...
                'fail_for_labsN',1:2);
            
            %cs  = iMessagesFramework.deserialize_par(css1);
            % initiate exchange class which would work on a client(worker's) side
            serverfbMPI  = MessagesFilebased('test_worker_some_fail');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            %             cs.labID = 0;
            %             serverfbMPI= serverfbMPI.init_framework(cs);
            clob = onCleanup(@()finalize_all(serverfbMPI));
            css1= serverfbMPI.gen_worker_init(1,3);
            css2= serverfbMPI.gen_worker_init(2,3);
            css3= serverfbMPI.gen_worker_init(3,3);
            
            
            je_initMess = serverfbMPI.build_je_init('JETester');
            job1_initMess = InitMessage(common_job_param,1,true,1);
            job2_initMess = InitMessage(common_job_param,1,true,2);
            job3_initMess = InitMessage(common_job_param,2,true,3);
            
            % Prepare control sequences for two jobs:
            % job 1
            [ok,err_mess] = serverfbMPI.send_message(1,je_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(1,job1_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            % job 2
            [ok,err_mess] = serverfbMPI.send_message(2,je_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(2,job2_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            
            % job 3
            [ok,err_mess] = serverfbMPI.send_message(3,je_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(3,job3_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            
            if verLessThan('matlab','8.1')
                if verLessThan('matlab','7.14')
                    warning('Singleton does not work properly on Matlab 2011a/b. not testing workers');
                    return
                elseif strcmpi(computer,'pcwin')
                    warning('Singleton does not work properly on Matlab 2012/b 32bit version. Not testing workers');
                    return
                end
            end
            % workers change config folder to its own value so ensure it
            % will be reverted to the initial value
            cs = config_store.instance();
            obj.current_config_folder = cs.config_folder;
            clob1 = onCleanup(@()(set_config_path(cs,obj.current_config_folder)));
            
            file3= fullfile(obj.working_dir,'test_jobDispatcherL3_nf1.txt');
            file3a= fullfile(obj.working_dir,'test_jobDispatcherL3_nf2.txt');
            
            
            clob2 = onCleanup(@()delete(file3,file3a));
            
            
            % start three client jobs, two should fail
            % second needs to start first as it will report its profess to
            % the lab1
            obj.worker_h(css3);
            obj.worker_h(css2);
            obj.worker_h(css1);
            % all workers reply 'started' to node1 as it is cluster
            % control message
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'failed')
            assertEqual(numel(message.payload),3);
            
            assertTrue(exist(file3,'file')==2);
            assertTrue(exist(file3a,'file')==2);
            
            
            assertTrue(isa(message.payload{1},'MException'))
            assertTrue(isa(message.payload{2},'MException'))
            assertEqual(message.payload{3},'Job 3 generated 2 files')
            
            
        end
        
        function test_worker(obj)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            % build jobs data
            common_job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            %cs  = iMessagesFramework.deserialize_par(css1);
            % initiate exchange class which would work on a client(worker's) side
            serverfbMPI  = MessagesFilebased('test_worker');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            %             cs.labID = 0;
            %             serverfbMPI= serverfbMPI.init_framework(cs);
            clob = onCleanup(@()finalize_all(serverfbMPI));
            css1= serverfbMPI.gen_worker_init(1,2);
            css2= serverfbMPI.gen_worker_init(2,2);
            
            
            je_initMess = serverfbMPI.build_je_init('JETester');
            job1_initMess = InitMessage(common_job_param,2,true,1);
            job2_initMess = InitMessage(common_job_param,1,true,3);
            
            % Prepare control sequences for two jobs:
            % job 1
            [ok,err_mess] = serverfbMPI.send_message(1,je_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(1,job1_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            % job 2
            [ok,err_mess] = serverfbMPI.send_message(2,je_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(2,job2_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            
            if verLessThan('matlab','8.1')
                if verLessThan('matlab','7.14')
                    warning('Singleton does not work properly on Matlab 2011a/b. not testing workers');
                    return
                elseif strcmpi(computer,'pcwin')
                    warning('Singleton does not work properly on Matlab 2012/b 32bit version. Not testing workers');
                    return
                end
            end
            % workers change config folder to its own value so ensure it
            % will be reverted to the initial value
            cs = config_store.instance();
            obj.current_config_folder = cs.config_folder;
            clob1 = onCleanup(@()(set_config_path(cs,obj.current_config_folder)));
            
            file1= fullfile(obj.working_dir,'test_jobDispatcher1_nf1.txt');
            file1a= fullfile(obj.working_dir,'test_jobDispatcher1_nf2.txt');
            
            file2= fullfile(obj.working_dir,'test_jobDispatcher2_nf1.txt');
            clob2 = onCleanup(@()delete(file1,file1a,file2));
            
            
            % start two client jobs
            % second needs to start first as it will report its profess to
            % the lab1
            obj.worker_h(css2);
            obj.worker_h(css1);
            % all worker_v1s reply 'started' to node1 and node 1 reduces this
            % message to message from node 1 to node 0
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'started')
            
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file1a,'file')==2);
            assertTrue(exist(file2,'file')==2);
            
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertTrue(isempty(err_mess));
            
            assertEqual(message.mess_name,'completed')
            assertEqual(message.payload{1},'Job 1 generated 2 files')
            assertEqual(message.payload{2},'Job 2 generated 1 files')
            
            
        end
        
        function test_log_messages(obj)
            serverfbMPI  = MessagesFilebased('test_log_messages');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % set short time to fail interval to fail quickly in case of
            % various errors
            serverfbMPI.time_to_fail = 1;
            
            % generate 3 controls to have 3 filebased MPI pseudo-workers
            css1= serverfbMPI.gen_worker_init(1,3);
            csr1= serverfbMPI.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(csr1);
            css2= serverfbMPI.gen_worker_init(2,3);
            csr2= serverfbMPI.deserialize_par(css2);
            fbMPI2 = MessagesFilebased(csr2);
            css3= serverfbMPI.gen_worker_init(3,3);
            csr3= serverfbMPI.deserialize_par(css3);
            fbMPI3 = MessagesFilebased(csr3);
            
            common_job_param = 'dumy_not_used';
            % should be 3 different init messages for 3 workers but as we
            % do not test do_job, 1 message would be ok
            initMess = InitMessage(common_job_param,3,true,1);
            
            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je3 = je.init(fbMPI3,csr3,initMess);
            je2 = je.init(fbMPI2,csr2,initMess);
            je1 = je.init(fbMPI1,csr1,initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            % test log progress
            je3.log_progress(1,10,1,[]);
            je2.log_progress(2,10,2,[]);
            je1.log_progress(1,9,1.3,[]);
            
            [ok,err,mess] = serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'running');
            
            assertElementsAlmostEqual(mess.step,(1+2+1)/3);
            assertElementsAlmostEqual(mess.time_per_step,(1+2+1.3)/3);
            assertEqual(mess.n_steps,10);
            
            assertTrue(isfield(mess.payload,'worker_logs'));
            assertEqual(numel(mess.payload.worker_logs),3);
            
        end
        
        function test_log_progress_with_fail(obj)
            serverfbMPI  = MessagesFilebased('test_log_progress');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % generate 3 controls to have 3 filebased MPI pseudo-workers
            css1= serverfbMPI.gen_worker_init(1,3);
            csr1= serverfbMPI.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(csr1);
            css2= serverfbMPI.gen_worker_init(2,3);
            csr2= serverfbMPI.deserialize_par(css2);
            fbMPI2 = MessagesFilebased(csr2);
            css3= serverfbMPI.gen_worker_init(3,3);
            csr3= serverfbMPI.deserialize_par(css3);
            fbMPI3 = MessagesFilebased(csr3);
            
            common_job_param = 'dumy_not_used';
            % should be 3 different init messages for 3 workers but as we
            % do not test do_job, 1 message would be ok
            initMess = InitMessage(common_job_param,3,true,1);
            
            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je3 = je.init(fbMPI3,csr3,initMess);
            je2 = je.init(fbMPI2,csr2,initMess);
            je1 = je.init(fbMPI1,csr1,initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            
            % test log progress
            je3.log_progress(1,10,1,[]);
            % on error, the framework would send cancelled messages
            je2.mess_framework.send_message(1,'cancelled');
            je2.mess_framework.send_message(3,'cancelled');
            % and then finish task with failure
            je2.finish_task(FailMessage('simulated fail'));
            try
                je1.log_progress(1,9,1.3,[]); %throws as no point to continue the execution after
            catch ME
                assertEqual(ME.identifier,'JOB_EXECUTOR:cancelled')
            end
            try
                je3.log_progress(2,9,1.3,[]); %throws as no point to continue the execution after
            catch ME
                assertEqual(ME.identifier,'JOB_EXECUTOR:cancelled')
            end
            je3.finish_task(FailMessage('job cancelled'));
            
            je1.finish_task(FailMessage('job canceled',ME));
            %
            % Server expects  to receive "running" message
            [ok,err,mess] = serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
            % but in fact got 'failed'
            assertEqual(mess.mess_name,'failed');
            assertEqual(numel(mess.payload),3)
            assertTrue(isa(mess.payload{1},'MException'));
            assertTrue(isa(mess.payload{2},'MException'));            
            assertTrue(isa(mess.payload{3},'MException'));
            
           
            serverfbMPI.clear_messages();
            
            % calculate run on the basis of partial log  messages
            je3.log_progress(5,10,1,[]);
            je1.log_progress(4,9,1.3,[]);
            [ok,err,mess] = serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'running');
            assertEqual(numel(mess.payload),1)
            assertTrue(isfield(mess.payload,'worker_logs'));
            wkl = mess.payload.worker_logs;
            assertEqual(numel(wkl),2)
            assertTrue(isstruct(wkl{1}));
            assertTrue(isstruct(wkl {2}));
            %-------------------------------------------------------------
            je1.mess_framework.clear_messages();
            je2.mess_framework.clear_messages();
            je3.mess_framework.clear_messages();            
            
            je3.log_progress(9,10,1,[]);
            je2.finish_task(FailMessage('simulated fail wk2'));
            je2.mess_framework.send_message(3,'cancelled');  
            try
                je3.log_progress(10,10,1.3,[]); %throws as no point to contiunue the execution after
            catch ME
                assertEqual(ME.identifier,'JOB_EXECUTOR:cancelled')
            end
            je3.finish_task(FailMessage('Job Canceled',ME));            
            
            je1.finish_task(FailMessage('simulated fail wk1'));
            
            [ok,err,mess] = serverfbMPI.receive_message(1,'running');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'failed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),3); % one job is presumably in running, though it does not matter any more
            assertTrue(isa(mess.payload{1},'MException'));
            assertTrue(isa(mess.payload{2},'MException'));
            assertTrue(isa(mess.payload{3},'MException'));            
            %assertTrue(isstruct(mess.payload{3}));
            
        end
        
        
        %
        function test_finish_task_reduce_messages(obj)
            serverfbMPI  = MessagesFilebased('test_finish_task_reduce_mess');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % generate 3 controls to have 3 filebased MPI pseudo-workers
            css1= serverfbMPI.gen_worker_init(1,3);
            csr1= serverfbMPI.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(csr1);
            css2= serverfbMPI.gen_worker_init(2,3);
            csr2= serverfbMPI.deserialize_par(css2);
            fbMPI2 = MessagesFilebased(csr2);
            css3= serverfbMPI.gen_worker_init(3,3);
            csr3= serverfbMPI.deserialize_par(css3);
            fbMPI3 = MessagesFilebased(csr3);
            
            common_job_param = 'dumy_not_used';
            % should be 3 different init messages for 3 workers but as we
            % do not test do_job, 1 message would be ok
            initMess = InitMessage(common_job_param,3,true,1);
            
            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je3 = je.init(fbMPI3,csr3,initMess);
            je2 = je.init(fbMPI2,csr2,initMess);
            je1 = je.init(fbMPI1,csr1,initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            
            je3.task_outputs = {'Successfully completed task3'};
            je2.task_outputs = {'Successfully completed task2',2};
            je1.task_outputs = {'Successfully completed task1',1};
            je3.finish_task();
            je2.finish_task();
            je1.finish_task();
            
            
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),3);
            
            
            je3.finish_task();
            je2.task_outputs = '';
            je2.finish_task(FailMessage('test fail'));
            je1.finish_task();
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'failed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),3);
        end
        
        
        function test_finish_1task_reduce_messages(obj)
            serverfbMPI  = MessagesFilebased('test_finish_1task_reduce_mess');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % generate 3 controls to have 3 filebased MPI pseudo-workers
            css1= serverfbMPI.gen_worker_init(1,1);
            csr1= serverfbMPI.deserialize_par(css1);
            fbMPI1 = MessagesFilebased(csr1);
            
            common_job_param = 'dumy_not_used';
            % should be 3 different init messages for 3 workers but as we
            % do not test do_job, 1 message would be ok
            initMess = InitMessage(common_job_param,3,true,1);
            
            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je1 = je.init(fbMPI1,csr1,initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            
            je1.task_outputs = {'Successfully completed task1',1};
            je1.finish_task();
            
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),1);
        end
        %
        function test_do_job(this)
            % Its a self test of the JETester to be sure its do_job is fine
            % not testing anything but JETester
            common_job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            initMess = InitMessage(common_job_param,1,true);
            css = iMessagesFramework.build_worker_init(this.working_dir,'test_do_job',1,1);
            cs  = iMessagesFramework.deserialize_par(css);
            % initiate exchange class which would work on a client(worker's) side
            fbMPI = MessagesFilebased();
            fbMPI = fbMPI.init_framework(cs);
            clob = onCleanup(@()finalize_all(fbMPI));
            
            % initiate exchange class which would work on the server's side
            cs.labID = 0;
            serverfbMPI  = MessagesFilebased(cs);
            
            % initiate job executor would working on a client side.
            je = JETester();
            je = je.init(fbMPI,cs,initMess);
            
            % got reply from the client
            [ok,err,mess]=serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'started');
            
            % run do_job method
            job_result_file = fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            clob1 = onCleanup(@()delete(job_result_file));
            %
            je=je.do_job();
            %
            assertTrue(exist(job_result_file,'file')==2);
            
            
            assertFalse(isempty(je.task_outputs));
            assertEqual(je.task_outputs,'Job 1 generated 1 files')
            
            % finalize the job run on worker and return final results
            [ok,mess] =je.finish_task();
            assertTrue(ok);
            assertTrue(isempty(mess));
            
            % receive the final results on the server and verify their
            % correctness.
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err));
            assertEqual(je.task_outputs,mess.payload{1})
        end
        %
        function test_finish_task_tester(obj)
            serverfbMPI  = MessagesFilebased('test_finish_task_tester');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            
            clob = onCleanup(@()finalize_all(serverfbMPI));
            cf = config_store.instance().config_folder;
            function reset_config(cf)
                config_store.instance('clear');
                config_store.set_config_folder(cf);
            end
            clob1 = onCleanup(@()reset_config(cf));
            % generate 2 control to have 2 filebased MPI pseudo-workers with
            % headnode 1
            css1= serverfbMPI.gen_worker_init(1,2);
            css2= serverfbMPI.gen_worker_init(2,2);
            
            ok = finish_task_tester(css2);
            assertTrue(ok);
            % this will wait until worker 2 completes
            ok = finish_task_tester(css1);
            assertTrue(ok);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            
        end
    end
    
end
