classdef test_job_executor< MPI_Test_Common
    % TODO -- modify these tests to run with every frameworks
    %
    properties
        current_config_folder;
        worker_h = @(str)parallel_worker(str,false);
    end
    methods

        function this=test_job_executor(name)
            if ~exist('name', 'var')
                name = 'test_job_executor';
            end
            % testing this on file-based framework only
            this = this@MPI_Test_Common(name,'herbert');
            this.working_dir = tmp_dir;
        end

        function setUp(~)
            mis = MPI_State.instance();
            mis.is_tested = true;

        end

        function tearDown(~)
            mis = MPI_State.instance();
            mis.is_deployed = false;
            mis.is_tested= false;
        end

        function [serverfbMPI,fbMPIs,initMess]=...
                init_pseudojob(obj,test_folder_name,n_workers)
            % initialize
            serverfbMPI  = MessagesFilebased(test_folder_name);
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            % set short time to fail interval to fail quickly in case of
            % various errors
            serverfbMPI.time_to_fail = 1;
            serverfbMPI.set_is_tested(true); % disable barriers

            fbMPIs= cell(1,n_workers);
            for i=1:n_workers
                % generate 3 controls to have 3 filebased MPI pseudo-workers
                css1= serverfbMPI.get_worker_init('MessagesFilebased',i,n_workers);
                csr1= serverfbMPI.deserialize_par(css1);
                fbMPIs{i} = MessagesFilebased(csr1);
                fbMPIs{i}.set_is_tested(true); % disable barriers
            end

            common_job_param = 'dummy_not_used';
            % should be n_workers different init messages for all n_workers
            %  but as we do not test do_job, 1 message would be ok
            initMess = InitMessage(common_job_param,3,true,1);
        end

        function send_init_messages(obj,serverfbMPI,je_common_init,je_worker_init)
            % Prepare control sequences for two jobs:
            % job 1
            [ok,err_mess] = serverfbMPI.send_message(1,je_common_init);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(1,je_worker_init{1});
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            % job 2
            [ok,err_mess] = serverfbMPI.send_message(2,je_common_init);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(2,je_worker_init{2});
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);

            % job 3
            [ok,err_mess] = serverfbMPI.send_message(3,je_common_init);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(3,je_worker_init{3});
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);

        end

        function test_worker_fails(obj)
            % build jobs data, stating that labs 1 and 2 should fail.
            common_job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt',...
                'fail_for_labsN',1:2);
            in_data = iMessagesFramework.build_worker_init(tmp_dir,...
                'test_worker_some_fail_0','MessagesFilebased',0,3,'test_mode');

            % initiate exchange class which would work on a client(worker's) side
            serverfbMPI  = MessagesFilebased(in_data );
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            %
            clob = onCleanup(@()finalize_all(serverfbMPI));
            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,3,'test_mode');
            css2= serverfbMPI.get_worker_init('MessagesFilebased',2,3,'test_mode');
            css3= serverfbMPI.get_worker_init('MessagesFilebased',3,3,'test_mode');
            %
            je_initMess = JobExecutor.build_worker_init('JETester');
            je_worker_init = {InitMessage(common_job_param,1,true,1),...
                InitMessage(common_job_param,1,true,2),...
                InitMessage(common_job_param,2,true,3)};

            obj.send_init_messages(serverfbMPI,je_initMess,je_worker_init);

            if verLessThan('matlab','8.1')
                if verLessThan('matlab','7.14')
                    skipTest('Singleton does not work properly on Matlab 2011a/b. not testing workers');
                elseif strcmpi(computer,'pcwin')
                    skipTest('Singleton does not work properly on Matlab 2012/b 32bit version. Not testing workers');
                end
            end
            mess_folder = serverfbMPI.mess_exchange_folder;
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
            [~,~,je3]=obj.worker_h(css3);
            [~,~,je2]=obj.worker_h(css2);
            % defer receiving the interrupt message before je1 initialized
            % properly. If it does not, it is an unrecoverable failure, but
            % probability for this to happen in real life is low.
            interrupt_generated = je2.mess_framework.mess_file_name(1,'interrupt');
            [~,fn,fe] = fileparts(interrupt_generated);
            interrupt_generated = fullfile(mess_folder,[fn,fe]); % folder have been migrated
            % so need to refer to the previous folder
            assertTrue(is_file(interrupt_generated))

            tmp_dest = fullfile(mess_folder,'test_worker_fails_tmp_interrupt.mat');
            movefile(interrupt_generated ,tmp_dest);
            % end defer.
            [~,~,je1]=obj.worker_h(css1);

            % return interrupt back
            movefile(tmp_dest,interrupt_generated);
            %
            % all workers reply 'started' to node1 as it is cluster
            % control message
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'failed')
            assertEqual(numel(message.payload),2);

            assertTrue(is_file(file3));
            assertTrue(is_file(file3a));

            assertTrue(isa(message.payload{1}.error,'MException'))
            %assertTrue(isa(message.payload{2}.error,'MException'))
            assertEqual(message.payload{2},'Job 3 generated 2 files')
            %-------------------------------------------------------------
            % clear remaining from the previous job.
            serverfbMPI.clear_messages();
            je3.mess_framework.clear_messages();
            je2.mess_framework.clear_messages();
            je1.mess_framework.clear_messages();
            serverfbMPI.migrate_message_folder();
            %--------------------------------------------------------------
            obj.send_init_messages(serverfbMPI,je_initMess,je_worker_init);

            % folder migrated!
            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,3,'test_mode');
            css2= serverfbMPI.get_worker_init('MessagesFilebased',2,3,'test_mode');
            css3= serverfbMPI.get_worker_init('MessagesFilebased',3,3,'test_mode');

            % now its necessary otherwise worker v1 will wait for this
            % message
            me = aMessage('ready');
            me.payload = 3;
            je3.mess_framework.send_message(1,me);
            me.payload = 2;
            je2.mess_framework.send_message(1,me);
            [~,~,je1]=obj.worker_h(css1);
            [~,~,je2]=obj.worker_h(css2);

            % receive message which je1 should wait for when running in
            % parallel
            mess_folder = serverfbMPI.mess_exchange_folder;
            started_mess_file = je2.mess_framework.mess_file_name(1,'started');
            [~,fn,fe] = fileparts(started_mess_file); % folder migrated;
            started_mess_file = fullfile(mess_folder,[fn,fe]);
            assertTrue(is_file(started_mess_file));
            delete(started_mess_file); % this should be done by synchronous je1

            %
            %             [ok,err_mess,messs] = je1.mess_framework.receive_message(2,'started');
            %             assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            %             assertEqual(messs.mess_name,'failed');
            [~,~,je3]=obj.worker_h(css3);

            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'failed');
            % as the fail message was sent first and in asynchronous mode,
            % only first worker reported failure
            assertEqual(numel(message.payload),1);

            next_exch = serverfbMPI.next_message_folder_name;
            assertTrue(is_folder(next_exch))
            rmdir(next_exch,'s');
        end

        function test_worker(obj)
            % build jobs data
            common_job_param = struct('filepath',obj.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');

            %cs  = iMessagesFramework.deserialize_par(css1);
            % initiate exchange class which would work on a client(worker's) side
            in_data = iMessagesFramework.build_worker_init(tmp_dir,...
                'test_worker','MessagesFilebased',0,2,'test_mode');

            serverfbMPI  = MessagesFilebased(in_data);
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            %
            clob = onCleanup(@()finalize_all(serverfbMPI));
            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,2,'test_mode');
            css2= serverfbMPI.get_worker_init('MessagesFilebased',2,2,'test_mode');


            je_initMess = JobExecutor.build_worker_init('JETester');
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
                    skipTest('Singleton does not work properly on Matlab 2011a/b. not testing workers');
                elseif strcmpi(computer,'pcwin')
                    skipTest('Singleton does not work properly on Matlab 2012/b 32bit version. Not testing workers');
                end
            end
            % workers change config folder to its own value so ensure it
            % will be reverted to the initial value
            cs = config_store.instance();
            obj.current_config_folder = cs.config_folder;
            clob1 = onCleanup(@()(set_config_path(cs,obj.current_config_folder,'-clear')));

            file1= fullfile(obj.working_dir,'test_jobDispatcher1_nf1.txt');
            file1a= fullfile(obj.working_dir,'test_jobDispatcher1_nf2.txt');

            file2= fullfile(obj.working_dir,'test_jobDispatcher2_nf1.txt');
            clob2 = onCleanup(@()delete(file1,file1a,file2));


            % start two client jobs
            % second needs to start first as it will report its profess to
            % the lab1
            [~,~,je2]=obj.worker_h(css2);
            assertFalse(isempty(je2))
            [~,~,je1]=obj.worker_h(css1);
            assertFalse(isempty(je1))

            [ok,err_mess,mess]=serverfbMPI.receive_message(1,'ready');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertFalse(isempty(mess));
            assertEqual(mess.payload,[1;2]);

            % all worker_v1s reply 'started' to node1 and node 1 reduces this
            % message to message from node 1 to node 0
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'started')


            assertTrue(is_file(file1));
            assertTrue(is_file(file1a));
            assertTrue(is_file(file2));

            [ok,err_mess,message] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertTrue(isempty(err_mess));

            assertEqual(message.mess_name,'completed')
            assertEqual(message.payload{1},'Job 1 generated 2 files')
            assertEqual(message.payload{2},'Job 2 generated 1 files')

            % this will delete the message folder where workers have
            % migrated to
            % the clean-up should clear the rest.
            rmdir(je2.mess_framework.mess_exchange_folder,'s');
            %rmdir(serverfbMPI.next_message_folder_name,'s');

        end

        function test_log_messages(obj)

            [serverfbMPI,fbMPIs,initMess]=...
                obj.init_pseudojob('test_log_messages',3);
            clob = onCleanup(@()finalize_all(serverfbMPI));

            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je3 = je.init(fbMPIs{3},fbMPIs{3},initMess);
            mess_name3 = fbMPIs{3}.mess_file_name(1,'started');
            assertTrue(is_file(mess_name3))

            je2 = je.init(fbMPIs{2},fbMPIs{2},initMess);
            mess_name2 = fbMPIs{2}.mess_file_name(1,'started');
            assertTrue(is_file(mess_name2))

            je1 = je.init(fbMPIs{1},fbMPIs{1},initMess);
            assertFalse(is_file(mess_name3))
            assertFalse(is_file(mess_name2))
            mess_name0 = fbMPIs{1}.mess_file_name(0,'started');
            assertTrue(is_file(mess_name0))

            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');

            % test log progress
            je3.log_progress(1,10,1,[]);
            mess_name3 = fbMPIs{3}.mess_file_name(1,'log');
            assertTrue(is_file(mess_name3))

            je2.log_progress(2,10,2,[]);
            mess_name2 = fbMPIs{2}.mess_file_name(1,'log');
            assertTrue(is_file(mess_name2))

            je1.log_progress(1,9,1.3,[]);

            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'log');

            assertElementsAlmostEqual(mess.step,(1+2+1)/3);
            assertElementsAlmostEqual(mess.time_per_step,(1+2+1.3)/3);
            assertEqual(mess.n_steps,10);

            assertTrue(isfield(mess.payload,'worker_logs'));
            assertEqual(numel(mess.payload.worker_logs),3);


            % test log progress
            je3.log_progress(2,10,2,[]);
            mess_name3 = fbMPIs{3}.mess_file_name(1,'log');
            assertTrue(is_file(mess_name3))


            je1.log_progress(2,9,3,[]);

            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'log');

            assertElementsAlmostEqual(mess.step,(2+2)/2);
            assertElementsAlmostEqual(mess.time_per_step,(2+3)/2);
            assertEqual(mess.n_steps,10);


        end

        function test_log_progress_with_fail(obj)
            %
            [serverfbMPI,fbMPIs,initMess]=...
                obj.init_pseudojob('test_log_progress_with_fail',3);
            clob = onCleanup(@()finalize_all(serverfbMPI));

            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            % sends 'started 3' message
            je3 = je.init(fbMPIs{3},fbMPIs{3},initMess);
            % sends 'started 2' message
            je2 = je.init(fbMPIs{2},fbMPIs{2},initMess);
            % Nect one collects all started messages from other fameworks
            % and returns "started" to the headnode
            je1 = je.init(fbMPIs{1},fbMPIs{1},initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');

            % test log progress
            je3.log_progress(1,10,1,[]);
            % on error, the framework would send cancelled messages
            je2.mess_framework.send_message(1,'cancelled');
            je2.mess_framework.send_message(3,'cancelled');
            % and then finish task with failure
            je2.finish_task(FailedMessage('simulated fail'),'-asynch');
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
            je3.finish_task(FailedMessage('job cancelled'),'-asynch');

            je1.finish_task(FailedMessage('job cancelled',ME),'-asynch');
            %
            % Server expects  to receive "running" message
            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);
            % but in fact got 'failed'
            assertEqual(mess.mess_name,'failed');
            assertEqual(numel(mess.payload),3)
            assertTrue(isa(mess.payload{1}.error,'MException'));
            assertTrue(isa(mess.payload{2}.error,'MException'));
            assertTrue(isa(mess.payload{3}.error,'MException'));


            serverfbMPI.clear_messages();

            % calculate run on the basis of partial log  messages
            je3.log_progress(5,10,1,[]);
            je1.log_progress(4,9,1.3,[]);
            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'log');
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
            je2.finish_task(FailedMessage('simulated fail wk2'),'-asynch');
            je2.mess_framework.send_message(3,'cancelled');
            try
                je3.log_progress(10,10,1.3,[]); %throws as no point to contiunue the execution after
            catch ME
                assertEqual(ME.identifier,'JOB_EXECUTOR:cancelled')
            end
            je3.finish_task(FailedMessage('Job Cancelled',ME),'-asynch');

            je1.finish_task(FailedMessage('simulated fail wk1'),'-asynch');

            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'failed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),3); % one job is presumably in log, though it does not matter any more
            assertTrue(isa(mess.payload{1}.error,'MException'));
            assertTrue(isa(mess.payload{2}.error,'MException'));
            assertTrue(isa(mess.payload{3}.error,'MException'));
            %assertTrue(isstruct(mess.payload{3}));

        end

        function test_finish_task_reduce_messages(obj)
            %
            [serverfbMPI,fbMPIs,initMess]=...
                obj.init_pseudojob('test_finish_task_reduce_messages',3);
            clob = onCleanup(@()finalize_all(serverfbMPI));


            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je3 = je.init(fbMPIs{3},fbMPIs{3},initMess);
            je2 = je.init(fbMPIs{2},fbMPIs{2},initMess);
            je1 = je.init(fbMPIs{1},fbMPIs{1},initMess);

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
            serverfbMPI.clear_messages();


            je3.finish_task();
            je2.task_outputs = '';
            je2.finish_task(FailedMessage('test fail'));
            je1.finish_task();
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'failed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),3);
        end

        function test_finish_1task_receive_messages(obj)
            [serverfbMPI,fbMPIs,initMess]=...
                obj.init_pseudojob('test_finish_1task_receie_mess',1);
            clob = onCleanup(@()finalize_all(serverfbMPI));
            fbMPI1 = fbMPIs{1};

            % Initialize job executor to simulate 1 worker
            je = JETester();
            je1 = je.init(fbMPI1,fbMPI1,initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');

            je1.task_outputs = {'Successfully completed task1',1};
            je1.finish_task('-asynch');

            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),1);
        end

        function test_finish_3tasks_reduce_messages(obj)
            [serverfbMPI,fbMPIs,initMess]=...
                obj.init_pseudojob('finish_3tasks_reduce_messages',3);
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % Initialize 3 job executors to simulate 3 workers
            je = JETester();
            je3 = je.init(fbMPIs{3},fbMPIs{3},initMess);
            je2 = je.init(fbMPIs{2},fbMPIs{2},initMess);
            je1 = je.init(fbMPIs{1},fbMPIs{1},initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');


            je3=je3.reduce_send_message(LogMessage(),'log',[],false);
            assertTrue(is_file(fbMPIs{3}.mess_file_name(1,'log')));
            je2=je2.reduce_send_message(LogMessage(),'log',[],false);
            assertTrue(is_file(fbMPIs{2}.mess_file_name(1,'log')));

            je1=je1.reduce_send_message(LogMessage(),'log',[],false);
            assertFalse(is_file(fbMPIs{3}.mess_file_name(1,'log')));
            assertFalse(is_file(fbMPIs{2}.mess_file_name(1,'log')));
            assertTrue(is_file(fbMPIs{1}.mess_file_name(0,'log')));


            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'log');
            assertTrue(iscell(mess.payload));
            assertEqual(numel(mess.payload),3);
        end

        function test_do_job(this)
            % Its a self test of the JETester to be sure its do_job is fine
            % not testing anything but JETester
            common_job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            initMess = InitMessage(common_job_param,1,true);
            css = iMessagesFramework.build_worker_init(this.working_dir,...
                'test_do_job','MessagesFilebased',1,1);
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
            je = je.init(fbMPI,fbMPI,initMess);

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
            assertTrue(is_file(job_result_file));


            assertFalse(isempty(je.task_outputs));
            assertEqual(je.task_outputs,'Job 1 generated 1 files')

            % finalize the job run on worker and return final results
            [ok,mess] =je.finish_task('-asynch');
            assertTrue(ok);
            assertTrue(isempty(mess));

            % receive the final results on the server and verify their
            % correctness.
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err));
            assertEqual(je.task_outputs,mess.payload{1})
            assertEqual(mess.payload{1},je.task_outputs)
        end

        function test_finish_task_tester(obj)

            serverfbMPI  = MessagesFilebased('test_finish_task_tester');
            serverfbMPI.mess_exchange_folder = obj.working_dir;

            clob = onCleanup(@()finalize_all(serverfbMPI));
            cf = config_store.instance.config_folder;
            function reset_config(cf)
                config_store.instance('clear');
                config_store.set_config_folder(cf);
            end
            clob1 = onCleanup(@()reset_config(cf));
            % generate 2 control to have 2 filebased MPI pseudo-workers with
            % headnode 1
            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,2);
            css2= serverfbMPI.get_worker_init('MessagesFilebased',2,2);

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

        function test_init_mpiexec_mpi_fw(obj)
            if isempty(which('cpp_communicator'))
                skipTest('MPI framework executable is not available.');
            end
            serverfbMPI  = MessagesFilebased('test_init_mpiexec_fw');
            serverfbMPI.mess_exchange_folder = obj.working_dir;

            clob = onCleanup(@()finalize_all(serverfbMPI));
            cf = config_store.instance.config_folder;
            function reset_config(cf)
                config_store.instance('clear');
                config_store.set_config_folder(cf);
            end
            clob1 = onCleanup(@()reset_config(cf));
            % generate control with different types of frameworks.
            css1= serverfbMPI.get_worker_init('MessagesCppMPI_3wkrs_tester');

            ok = finish_task_tester(css1,3);
            assertTrue(ok);

            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            MPI_State.instance('clear');
        end

        function test_init_parpool_fw(obj)
            ok = license('checkout','Distrib_Computing_Toolbox');
            if ~ok
                skipTest('Distrib_Computing_Toolbox is not available on this machine. Not tested');
            else
                try
                    nl = numlabs();
                catch ME
                    if strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
                        skipTest('License for parallel computer toolbox is available but toolbox is not installed. Can not use parpool parallelization');
                    else
                        rethrow(ME);
                    end
                end
            end

            %
            serverfbMPI  = MessagesFilebased('test_init_parpool_fw');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            clob = onCleanup(@()finalize_all(serverfbMPI));

            cf = config_store.instance.config_folder;
            function reset_config(cf)
                config_store.instance('clear');
                config_store.set_config_folder(cf);
            end
            clob1 = onCleanup(@()reset_config(cf));
            % generate control with different types of frameworks.
            css1= serverfbMPI.get_worker_init('MessagesParpool',1,1);

            ok = finish_task_tester(css1);
            assertTrue(ok);

            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            MPI_State.instance('clear');
        end

        function test_fail_state_processor(obj)

            [serverfbMPI,fbMPIs,initMess]=...
                obj.init_pseudojob('fail_state_processor_tests',2);
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % Initialize 3 job executors to simulate 3 workers

            je = JETester();
            je2 = je.init(fbMPIs{2},fbMPIs{2},initMess);
            je1 = je.init(fbMPIs{1},fbMPIs{1},initMess);
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            %--------------------------------------------------------------
            % check job cancelled
            errm = MException('JOB_EXECUTOR:failed','fake error generated');
            err_mess = je2.process_fail_state(errm);
            [ok,err_mess]=je2.finish_task(err_mess);
            assertTrue(ok)
            assertTrue(isempty(err_mess))

            assertTrue(is_file(fbMPIs{2}.mess_file_name(1,'interrupt')));
            try
                je1.log_progress(2,10,3,[]);
            catch ERRm
                assertTrue(strcmpi(ERRm.identifier,'JOB_EXECUTOR:cancelled'));
            end
            err_mess=je1.process_fail_state(ERRm);
            [ok,err_mess]=je1.finish_task(err_mess);
            assertTrue(ok)
            assertTrue(isempty(err_mess))

            % asked for running, got failed
            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(MESS_CODES.ok,ok);
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'failed');

            assertEqual(numel(mess.payload),2)
            pl = mess.payload;
            assertTrue(isa(pl{1}.error,'MException'))
            assertTrue(isa(pl{2}.error,'MException'))

            assertEqual(pl{2}.fail_reason,'Task N2 failed at jobExecutor: JETester. Reason: fake error generated');
            %--------------------------------------------------------------
            % Check custom code exception on the head node
            errm = MException('CUSTOM_CODE:failed','fake failed message');
            err_mess = je1.process_fail_state(errm);
            % asynchronous in test mode as waits for other jobs to
            % complete

            try
                je1.finish_task(err_mess);
                no_inerrupt = true;
            catch ME
                no_inerrupt = false;
                assertEqual(ME.identifier,...
                    'MESSAGES_FRAMEWORK:runtime_error',...
                    'finish_task Should throw "blocking message requested" in test mode');
            end
            assertFalse(no_inerrupt,...
                'finish_task Should throw "blocking message requested" in test mode')

            [ok,err]=je1.finish_task(err_mess,'-asynch');
            assertTrue(ok)
            assertTrue(isempty(err))

            try
                je2.log_progress(2,10,3,[]);
            catch ERRm
                assertTrue(strcmpi(ERRm.identifier,'JOB_EXECUTOR:cancelled'));
                % under normal execution je1 will wait until cancel message
                % from second lab is received, but in the tests it executed
                % asynchronously so the message to lab2 will come later
                [ok,err,message]=fbMPIs{2}.receive_message(1,'cancelled');
                assertEqual(MESS_CODES.ok,ok);
                assertTrue(isempty(err));
                assertEqual(message.mess_name,'cancelled');
            end
            % asked for running, got failed from je1
            [ok,err,mess] = serverfbMPI.receive_message(1,'log');
            assertEqual(MESS_CODES.ok,ok);
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'failed');
        end

        function test_invalid_input(obj)
            skipTest('invalid arguments test disabled #817')
            if obj.ignore_test
                skipTest(obj.ignore_cause);
            end

            worker_name = obj.worker;
            orig_log = getenv('DO_PARALLEL_MATLAB_LOGGING');
            setenv('DO_PARALLEL_MATLAB_LOGGING','true');
            clOb = onCleanup(@()setenv('DO_PARALLEL_MATLAB_LOGGING',orig_log));
            %
            [ok,err] = feval(worker_name,'invalid_input');
            assertFalse(ok);
            assertTrue(isa(err,'MException'));

            pid = int64(feature('getpid'));
            log_file = fullfile(getuserdir,...
                sprintf('WORKER_V2_Process_%d_failure.log',pid));
            assertTrue(is_file(log_file));
            delete(log_file);
        end

        function test_unhandled_error_in_init(obj)
            if obj.ignore_test
                skipTest(obj.ignore_cause);
            end
            % build jobs data

            %cs  = iMessagesFramework.deserialize_par(css1);
            % initiate exchange class which would work on a client(worker's) side
            in_data = iMessagesFramework.build_worker_init(tmp_dir,...
                'test_worker','MessagesFilebased',0,2,'test_mode');

            serverfbMPI  = MessagesFilebased(in_data);
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            %
            clob = onCleanup(@()finalize_all(serverfbMPI));
            css1= serverfbMPI.get_worker_init('MessagesFilebased',1,2,'test_mode');

            css2 = serverfbMPI.get_worker_init('MessagesFilebased',2,2,'test_mode');
            csr2 = serverfbMPI.deserialize_par(css2);
            fbMPIs2 = MessagesFilebased(csr2);



            je_initMess = JobExecutor.build_worker_init('JETester');
            job1_initMess = InitMessage();
            job1_initMess.payload = 'invalid_initialization_info';


            % Prepare control sequences for two jobs:
            % job 1
            [ok,err_mess] = serverfbMPI.send_message(1,je_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            [ok,err_mess] = serverfbMPI.send_message(1,job1_initMess);
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);

            % workers change config folder to its own value so ensure it
            % will be reverted to the initial value
            cs = config_store.instance();
            obj.current_config_folder = cs.config_folder;
            clob1 = onCleanup(@()(set_config_path(cs,obj.current_config_folder)));

            % start  client job to fail
            % second needs to start first as it will report its profess to
            % the lab1

            % prepare ready message from other nodes for worker N1
            ms = aMessage('ready');
            ms.payload = 2;
            fbMPIs2.send_message(1,ms);

            worker_name = obj.worker;
            orig_log = getenv('DO_PARALLEL_MATLAB_LOGGING');
            setenv('DO_PARALLEL_MATLAB_LOGGING','true');
            clOb = onCleanup(@()setenv('DO_PARALLEL_MATLAB_LOGGING',orig_log));

            [ok,err,je]=feval(worker_name,css1);
            assertFalse(isempty(je));
            assertFalse(ok);
            assertTrue(isa(err,'MException'));

            pid = int64(feature('getpid'));
            log_file = fullfile(getuserdir,...
                sprintf('WORKER_V2_Process_%d_failure.log',pid));

            assertTrue(is_file(log_file))
            delete(log_file)
            % all worker_v1s reply 'started' to node1 and node 1 reduces this
            % message to message from node 1 to node 0
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'failed')
        end
        %
    end

end
