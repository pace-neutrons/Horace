classdef test_exchange_FileBasedMPI < exchange_common_tests
    
    properties
    end
    methods
        
        function obj = test_exchange_FileBasedMPI(name)
            if ~exist('name', 'var')
                name = 'test_exchange_FileBasedMPI';
            end
            cs  = iMessagesFramework.build_worker_init(tmp_dir, ...
                'test_FB_message', 'MessagesFilebased', 1, 3,'test_mode');
            
            obj = obj@exchange_common_tests(name,...
                'MessagesFileBasedMPI_mirror_tester','herbert',cs);
            obj.mess_name_fix = '';
        end
        
        function test_finalize_all(~)
            mf = MFTester('test_finalize_all');
            clon = onCleanup(@()finalize_all(mf));
            
            [ok, err] = mf.send_message(0, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            [ok, err] = mf.send_message(0, LogMessage());
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            ok = mf.receive_message(0, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            ok = mf.receive_message(0, 'log');
            assertEqual(ok, MESS_CODES.ok)
            
            
            [all_messages_names, task_ids] = mf.probe_all(0, 'log');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            
            ok = mf.is_job_canceled();
            assertFalse(ok);
            mf.finalize_all();
            ok = mf.is_job_canceled();
            assertTrue(ok);
        end
        
        function test_receive_all_mess_client_server(this)
            fii = iMessagesFramework.build_worker_init(this.working_dir, ...
                'FB_MPI_Test_recevie_all', 'MessagesFilebased', 0, 3,'test_mode');
            mf0 = MessagesFilebased(fii);
            
            clob = onCleanup(@()(mf0.finalize_all()));
            fii.labID = 1;
            mf1 = MessagesFilebased(fii);
            fii.labID = 2;
            mf2 = MessagesFilebased(fii);
            fii.labID = 3;
            mf3 = MessagesFilebased(fii);
            
            
            mess = StartingMessage();
            [ok, err] = mf0.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            [messo, task_id] = mf2.receive_all(0);
            
            assertEqual(numel(messo), 1);
            assertEqual(numel(task_id), 1);
            assertEqual(task_id(1), 0);
            assertEqual(messo{1}.mess_name, 'starting')
            
            ok = mf0.send_message(3, mess);
            assertEqual(ok, MESS_CODES.ok)
            
            [mess, task_id] = mf3.receive_all(0, 'starting');
            assertEqual(numel(mess), 1);
            assertEqual(numel(task_id), 1);
            assertEqual(task_id(1), 0);
            assertEqual(mess{1}.mess_name, 'starting')
            
            % Send 3 messages from "3 labs" and receive all of them
            % on the control lab
            ok = mf1.send_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            
            ok = mf2.send_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            
            ok = mf3.send_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            
            
            [mess, task_id] = mf0.receive_all();
            assertEqual(numel(mess), 3);
            assertEqual(numel(task_id), 3);
            assertEqual(task_id(1), 1);
            assertEqual(task_id(2), 2);
            assertEqual(task_id(3), 3);
        end
        
        function test_probe_all(this)
            fs = iMessagesFramework.build_worker_init(this.working_dir, ...
                'MFT_probe_all_messages', 'MessagesFilebased', 0, 5,'test_mode');
            
            m_host = MessagesFilebased(fs);
            clob = onCleanup(@()(m_host.finalize_all()));
            
            fr = iMessagesFramework.build_worker_init(this.working_dir, ...
                'MFT_probe_all_messages', 'MessagesFilebased', 3, 5,'test_mode');
            m3 = MessagesFilebased(fr);
            
            
            all_mess = m_host.probe_all(1);
            assertTrue(isempty(all_mess));
            
            
            mess = StartingMessage();
            % send message to itself
            [ok, err] = m_host.send_message(3, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            [all_mess, mid_from] = m3.probe_all();
            assertTrue(ismember('starting', all_mess))
            assertFalse(ismember('started', all_mess))
            assertEqual(mid_from, 0);
            
            
            [ok, err] = m3.send_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess = LogMessage();
            [ok, err] = m3.send_message(0, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            % HACK: This is the test, confirming that files written one
            % after another can have random write date, despite often they
            % have dates following the write order.
            % Because of this feature, the test fails randomly so the following row
            % is commented for the tests reliability. It is extremely useful
            % for testing various filesystems though and common
            % understanding of the situation
            %[all_mess, mid_from] = m_host.probe_all(3);
            
            [all_mess, mid_from] = m_host.probe_all(3,'log'); % this always works but not what we wanted to test.
            assertEqual(numel(all_mess), 1);
            assertEqual(all_mess{1}, 'log');
            assertEqual(mid_from(1), 3);
            
            
            mess = FailedMessage('failed');
            [ok, err] = m3.send_message(0, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess = LogMessage();
            [ok, err] = m3.send_message(0, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            
            [all_mess, id_from] = m_host.probe_all();
            
            % failed overwrites log despite log send later
            assertEqual(numel(all_mess), 1);
            assertEqual(all_mess{1}, 'interrupt');
            assertEqual(id_from(1), 3);
            
        end
        
        function lock_file = build_fake_inverse_lock(~, mf, mess_name)
            % file write lock build when message is send , but for
            % mirrored target i.e. when send message is actually reflacted
            % from target and written as if send back from target.
            mess_file = ...
                mf.inverse_fname_f(mess_name,5,mf.labIndex);
            
            [fp, fn] = fileparts(mess_file);
            lock_file = fullfile(fp, [fn, '.lockw']);
            fh = fopen(lock_file, 'w');
            fclose(fh);
        end
        
        function lock_file = build_fake_lock(~, mf, mess_name)
            % file write lock normally build when message is written.
            mess_file = mf.mess_file_name(5,mess_name,mf.labIndex);
            
            [fp, fn] = fileparts(mess_file);
            lock_file = fullfile(fp, [fn, '.lockw']);
            fh = fopen(lock_file, 'w');
            fclose(fh);
        end
        
        function test_ignore_locked(obj)
            % test verifies that filebased messages which have lock are not
            % observed by the system until unlocked.
            function del_file(fname)
                if is_file(fname)
                    delete(fname);
                end
            end
            cs  = iMessagesFramework.build_worker_init(tmp_dir, ...
                'MFT_ignore_locked_messages', 'MessagesFilebased', 0, 5,'test_mode');
            
            mf = MessagesFileBasedMPI_mirror_tester(cs);
            clob = onCleanup(@()(mf.finalize_all()));
            mf.time_to_fail=2;
            
            all_mess = mf.probe_all(1);
            assertTrue(isempty(all_mess));
            
            
            mess = aMessage('queued');
            % send message to itself
            [ok, err] = mf.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            [all_mess, mid_from] = mf.probe_all();
            assertTrue(ismember('queued', all_mess))
            assertFalse(ismember('started', all_mess))
            assertEqual(mid_from, 5);
            [all_mess, mid_from] = mf.probe_all('all','queued');
            assertTrue(ismember('queued', all_mess))
            assertFalse(ismember('started', all_mess))
            assertEqual(mid_from, 5);
            
            
            lock_queued = obj.build_fake_inverse_lock(mf, 'queued');
            clob_lock1 = onCleanup(@()del_file(lock_queued));
            
            [all_mess,mid_from] = mf.probe_all();
            assertTrue(isempty(all_mess));
            assertTrue(isempty(mid_from));
            [all_mess, mid_from] = mf.probe_all('all','queued');
            assertTrue(isempty(all_mess));
            assertTrue(isempty(mid_from));
            
            % send another message to itself
            [ok, err] = mf.send_message(5, 'started');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [all_mess, mid_from] = mf.probe_all();
            assertTrue(ismember('started', all_mess))
            assertEqual(mid_from, 5);
            
            % create fake lock:
            lock_started = obj.build_fake_inverse_lock(mf, 'started');
            clob_lock2 = onCleanup(@()del_file(lock_started));
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            % create just lock (no file yet)
            lock_running = obj.build_fake_inverse_lock(mf, 'log');
            clob_lock3 = onCleanup(@()del_file(lock_running));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            
            delete(lock_queued);
            
            all_mess = mf.probe_all();
            assertTrue(ismember('queued', all_mess))
            assertEqual(mid_from, 5);
            
            delete(lock_started);
            
            all_mess = mf.probe_all();
            assertEqual(numel(all_mess), 1);
            % receved the most recent  message
            [ok, err,messR] = mf.receive_message(5, 'started','-synch');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(messR,aMessage('started'));
            
            all_mess = mf.probe_all();
            assertEqual(numel(all_mess), 1);
            
            [ok, err] = mf.receive_message(5, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
        end
        %------------------------------------------------------------------
        function clear_jenkins_var(~)
            setenv('JENKINS_URL');
            setenv('JOB_URL');
            setenv('JENKINS_HOME');
            setenv('JOB_NAME');
            setenv('WORKSPACE');
        end
        function test_folder_migration_on_fake_jenkins(obj)
            if is_jenkins() % do not run it on real Jenkins, it may mess
                % the whole enviroment
                return;
            end
            setenv('JENKINS_URL','http://some_url');
            setenv('JOB_URL','http://some_job_url');
            setenv('JENKINS_HOME',tmp_dir);
            setenv('JOB_NAME','test_jenkins_folder_migration');
            setenv('WORKSPACE',fullfile(tmp_dir,'test_jenkins_migration'));
            clearJenkinsSignature = onCleanup(@()clear_jenkins_var(obj));
            %
            assertTrue(is_jenkins);
            cs  = iMessagesFramework.build_worker_init(tmp_dir, ...
                'test_FB_message', 'MessagesFilebased', 1, 3,'test_mode');
            ocs = obj.tests_control_strcut;
            clearTestFile = onCleanup(@()set(obj,'tests_control_strcut',ocs));
            obj.tests_control_strcut = cs;
            
            
            mf = MessagesFileBasedMPI_mirror_tester();
            % this overwrites default config folder location!
            mf.mess_exchange_folder = tmp_dir;
            mf = mf.init_framework('test_jenkins_folder_migration');
            clob = onCleanup(@()mf.finalize_all());
            
            cfn = config_store.instance().config_folder_name;
            jfn = fullfile(tmp_dir, cfn,...
                mf.exchange_folder_name, mf.job_id);
            pause(1);
            assertTrue(is_folder(jfn));
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(isempty(the_mess));
            assertEqual(the_mess.mess_name, 'queued');
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mf.migrate_message_folder();
            assertFalse(is_folder(jfn));
            jnf = fullfile(tmp_dir, cfn, mf.exchange_folder_name, mf.job_id);
            assertTrue(is_folder(jnf));
            
            % message have gone
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertTrue(isempty(the_mess));
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(isempty(the_mess));
            assertEqual(the_mess.mess_name, 'queued');
            
            clear clob;
            assertFalse(is_folder(jnf));
            %
            clear clearJenkinsSignature;
            assertFalse(is_jenkins);            
        end
        
        function test_folder_migration(this)
            mf = MessagesFileBasedMPI_mirror_tester();
            mf.mess_exchange_folder = this.working_dir;
            mf = mf.init_framework('test_folder_migration');
            clob = onCleanup(@()mf.finalize_all());
            
            cfn = config_store.instance().config_folder_name;
            jfn = fullfile(this.working_dir, cfn,...
                mf.exchange_folder_name, mf.job_id);
            pause(10);
            assertTrue(is_folder(jfn));
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(isempty(the_mess));
            assertEqual(the_mess.mess_name, 'queued');
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mf.migrate_message_folder();
            assertFalse(is_folder(jfn));
            jnf = fullfile(this.working_dir, cfn, mf.exchange_folder_name, mf.job_id);
            assertTrue(is_folder(jnf));
            
            % message have gone
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertTrue(isempty(the_mess));
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(isempty(the_mess));
            assertEqual(the_mess.mess_name, 'queued');
            
            clear clob;
            assertFalse(is_folder(jnf));
        end
        %
        function test_shared_folder(this)
            mf = MessagesFileBasedMPI_mirror_tester();
            mf.mess_exchange_folder = this.working_dir;
            mf = mf.init_framework('test_shared_folder');
            clob = onCleanup(@()mf.finalize_all());
            
            cfn = config_store.instance().config_folder_name;
            jfn = fullfile(this.working_dir, cfn, mf.exchange_folder_name, mf.job_id);
            pause(10);
            assertTrue(is_folder(jfn));
            
            [ok, err] = mf.send_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok, err, the_mess] = mf.receive_message(7, 'queued');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(isempty(the_mess));
            assertEqual(the_mess.mess_name, 'queued');
            
            clear clob;
            assertFalse(is_folder(jfn));
        end
        %------------------------------------------------------------------
        function test_barrier(this)
            mf = MessagesFilebased('test_barrier');
            mf.mess_exchange_folder = this.working_dir;
            clob = onCleanup(@()mf.finalize_all());
            % create three pseudo-independent message exchange classes
            % presumably to run on independent workers
            css1 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 1, 3);
            cs1 = iMessagesFramework.deserialize_par(css1);
            css2 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 2, 3);
            cs2 = iMessagesFramework.deserialize_par(css2);
            css3 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 3, 3);
            cs3 = iMessagesFramework.deserialize_par(css3);
            
            fbMPI1 = MessagesFilebased(cs1);
            fbMPI2 = MessagesFilebased(cs2);
            fbMPI3 = MessagesFilebased(cs3);
            
            t0 = fbMPI3.time_to_fail;
            fbMPI3.time_to_fail = 0.1;
            % barrier fails at waiting time due to short time to fail
            try
                fbMPI3.labBarrier(false);
            catch ME
                assertEqual(ME.message, ...
                    'Timeout waiting for message "barrier" for task with id: 3');
            end
            fbMPI2.time_to_fail = 0.1;
            try
                fbMPI2.labBarrier(false);
            catch ME
                assertEqual(ME.message, ...
                    'Timeout waiting for message "barrier" for task with id: 2');
            end
            
            fbMPI3.time_to_fail = t0;
            fbMPI2.time_to_fail = t0;
            
            
            % will pass without delay as all other worker would reach the
            % barrier
            ok = fbMPI1.labBarrier(false);
            assertTrue(ok);
            
            % and other workers would pass barrier now
            ok = fbMPI3.labBarrier(false);
            assertTrue(ok);
            ok = fbMPI2.labBarrier(false);
            assertTrue(ok);
            
            % clear up the barrier messages
            [ok, err, mess] = fbMPI1.receive_message(2, 'barrier');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(mess.mess_name, 'barrier');
            
            [ok, err, mess] = fbMPI1.receive_message(3, 'barrier');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(mess.mess_name, 'barrier');
            
        end
        %
        function test_barrier_ignores_failed(this)
            % To deploy barrier, init should be not in test mode!
            
            mf = MessagesFilebased('test_barrier_fail');
            mf.mess_exchange_folder = this.working_dir;
            clob = onCleanup(@()mf.finalize_all());
            % create three pseudo-independent message exchange classes
            % presumably to run on independent workers
            css1 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 1, 3);
            cs1 = iMessagesFramework.deserialize_par(css1);
            css2 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 2, 3);
            cs2 = iMessagesFramework.deserialize_par(css2);
            css3 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 3, 3);
            cs3 = iMessagesFramework.deserialize_par(css3);
            
            fbMPI1 = MessagesFilebased(cs1);
            fbMPI1.set_is_tested(false); % ensure test mode is disabled
            fbMPI2 = MessagesFilebased(cs2);
            fbMPI2.set_is_tested(false); % ensure test mode is disabled
            fbMPI3 = MessagesFilebased(cs3);
            fbMPI3.set_is_tested(false); % ensure test mode is disabled
            
            
            t0 = fbMPI3.time_to_fail;
            fbMPI3.time_to_fail = 0.1;
            % barrier fails at waiting time due to short time to fail
            try
                fbMPI3.labBarrier(false);
            catch ME
                assertEqual(ME.message, ...
                    'Timeout waiting for message "barrier" for task with id: 3');
            end
            fbMPI2.time_to_fail = 0.1;
            [ok, err] = fbMPI2.send_message(1, FailedMessage('failed'));
            assertEqual(ok, MESS_CODES.ok, err)
            fbMPI2.time_to_fail = 0.1;
            try
                fbMPI2.labBarrier(false);
            catch ME
                assertEqual(ME.message, ...
                    'Timeout waiting for message "barrier" for task with id: 2');
            end
            
            % will pass without delay as all other worker would reach the
            % barrier
            ok = fbMPI1.labBarrier(false);
            assertTrue(ok);
            
            % and other workers would pass barrier now
            ok = fbMPI3.labBarrier(false);
            assertTrue(ok);
            ok = fbMPI2.labBarrier(false);
            assertTrue(ok);
            
            % clear up the barrier messages
            [ok, err, mess] = fbMPI1.receive_message(2, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'failed');
            
            [ok, err, mess] = fbMPI1.receive_message(2, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'failed'); % got it from messages cache. (disabled)
            % but barrier file exist
            barrier_file = fbMPI1.mess_file_name(fbMPI1.labIndex,'barrier',2);
            assertTrue(is_file(barrier_file));
            delete(barrier_file);
            
            [ok, err, mess] = fbMPI1.receive_message(3, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'barrier');
        end
        %
        function test_barrier_ignores_canceled(this)
            mf = MessagesFilebased('test_barrier_fail');
            mf.mess_exchange_folder = this.working_dir;
            clob = onCleanup(@()mf.finalize_all());
            % create three pseudo-independent message exchange classes
            % presumably to run on independent workers
            css1 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 1, 3);
            cs1 = iMessagesFramework.deserialize_par(css1);
            css2 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 2, 3);
            cs2 = iMessagesFramework.deserialize_par(css2);
            css3 = iMessagesFramework.build_worker_init( ...
                this.working_dir, mf.job_id, 'MessagesFilebased', 3, 3);
            cs3 = iMessagesFramework.deserialize_par(css3);
            
            fbMPI1 = MessagesFilebased(cs1);
            fbMPI1.set_is_tested(false); % ensure test mode is disabled
            fbMPI2 = MessagesFilebased(cs2);
            fbMPI2.set_is_tested(false); % ensure test mode is disabled
            fbMPI3 = MessagesFilebased(cs3);
            fbMPI3.set_is_tested(false); % ensure test mode is disabled
            
            [ok, err] = fbMPI2.send_message(1, 'canceled');
            assertEqual(ok, MESS_CODES.ok, err)
            
            t0 = fbMPI3.time_to_fail;
            fbMPI3.time_to_fail = 0.01; %
            % barrier fails at waiting time due to short time to fail
            try
                fbMPI3.labBarrier(false);
            catch ME
                assertEqual(ME.message, ...
                    'Timeout waiting for message "barrier" for task with id: 3');
            end
            fbMPI2.time_to_fail = 0.1;
            try
                fbMPI2.labBarrier(false);
            catch ME
                assertEqual(ME.message, ...
                    'Timeout waiting for message "barrier" for task with id: 2');
            end
            
            
            % will pass without delay as all other worker would reach the
            % barrier
            ok = fbMPI1.labBarrier(false);
            assertTrue(ok);
            % and other workers would pass barrier now
            ok = fbMPI3.labBarrier(false);
            assertTrue(ok);
            ok = fbMPI2.labBarrier(false);
            assertTrue(ok);
            
            % clear up the barrier messages
            [ok, err, mess] = fbMPI1.receive_message(2, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'canceled');
            
            [ok, err, mess] = fbMPI1.receive_message(3, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'barrier');
            
            % canceled is still there
            [ok, err, mess] = fbMPI1.receive_message(2, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'canceled');
        end
        %
        function test_data_queue(obj)
            css1 = iMessagesFramework.build_worker_init(obj.working_dir, ...
                'test_data_queue', 'MessagesFilebased', 1, 3);
            cs1 = iMessagesFramework.deserialize_par(css1);
            
            sender = MessagesFilebased(cs1);
            clob = onCleanup(@()sender.finalize_all());
            
            css2 = iMessagesFramework.build_worker_init(obj.working_dir, ...
                'test_data_queue', 'MessagesFilebased', 2, 3);
            cs2 = iMessagesFramework.deserialize_par(css2);
            receiver = MessagesFilebased(cs2);
            
            mess = DataMessage();
            mess.payload = 1;
            [ok, err] = sender.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, err);
            mess.payload = 2;
            [ok, err] = sender.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, err);
            
            mess.payload = 3;
            [ok, err] = sender.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, err);
            
            [all_mess, mid_from] = receiver.probe_all([], 'data');
            assertEqual(numel(all_mess), 1)
            assertEqual(mid_from, 1)
            
            [ok, err, mess] = receiver.receive_message(1, 'data');
            assertEqual(ok, MESS_CODES.ok, err);
            assertEqual(mess.payload, 1);
            
            [all_mess, mid_from] = receiver.probe_all([], 'data');
            assertEqual(numel(all_mess), 1)
            assertEqual(mid_from, 1)
            
            
            mess.payload = 4;
            [ok, err] = sender.send_message(2, mess);
            assertEqual(ok, MESS_CODES.ok, err);
            
            [ok, err, mess] = receiver.receive_message(1, 'data');
            assertEqual(ok, MESS_CODES.ok, err);
            assertEqual(mess.payload, 2);
            
            [ok, err, mess] = receiver.receive_message(1, 'data');
            assertEqual(ok, MESS_CODES.ok, err);
            assertEqual(mess.payload, 3);
            
            [ok, err, mess] = receiver.receive_message(1, 'data');
            assertEqual(ok, MESS_CODES.ok, err);
            assertEqual(mess.payload, 4);
            
            [all_mess, mid_from] = receiver.probe_all([], 'data');
            assertTrue(isempty(all_mess))
            assertTrue(isempty(mid_from))
        end
        %
        function test_message(this)
            fiis = iMessagesFramework.build_worker_init(this.working_dir, ...
                'test_message', 'MessagesFilebased', 0, 3);
            fii = iMessagesFramework.deserialize_par(fiis);
            
            
            job_param = struct('filepath', this.working_dir, ...
                'filename_template', 'test_jobDispatcher%d_nf%d.txt');
            
            mess = aMessage('started');
            mess.payload = job_param;
            
            mf0 = MFTester(fii);
            clob = onCleanup(@()mf0.finalize_all());
            [ok, err] = mf0.send_message(1, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess_fname = mf0.mess_file_name(1, 'started');
            assertTrue(is_file(mess_fname));
            
            fii.labID = 1;
            mf1 = MFTester(fii);
            [ok, err, the_mess] = mf1.receive_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(is_file(mess_fname)); % Message received
            
            cont = the_mess.payload;
            assertEqual(job_param,cont);
            
            init_mess = InitMessage('some init info');
            mess_fname = mf0.mess_file_name(1, 'init'); % name must be calculated before message send as it will be the next name otherwise
            
            [ok,err] = mf0.send_message(1,init_mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            assertTrue(is_file(mess_fname));
            
            [ok,err,the_mess]=mf1.receive_message(0,'init');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(the_mess.payload.common_data,'some init info');
            
            
            [all_messages_names,task_ids] = mf1.probe_all(0,'log');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            
            
            job_exchange_folder = fileparts(mess_fname);
            assertTrue(is_folder(job_exchange_folder))
            mf0.finalize_all();
            assertFalse(is_folder(job_exchange_folder))
        end
        %------------------------------------------------------------------
        function test_next_job_id_text(~)
            mf = MessagesFilebased('test_next_job_id');
            clObj = onCleanup(@()finalize_all(mf));
            
            jobID = mf.job_id;
            [~,name] = fileparts(mf.next_message_folder_name());
            
            dig_pos = regexp(jobID,'\d');
            
            nums = str2double(jobID(dig_pos));
            nm = nums+1;
            
            assertEqual(name,['test_next_job_id_',num2str(nm)]);
        end
        %
        function test_next_job_id_num1(~)
            mf = MessagesFilebased();
            mf.job_id = 'test_next_job1_id_num_1';
            clObj = onCleanup(@()finalize_all(mf));
            
            jobID = mf.job_id;
            [~,name] = fileparts(mf.next_message_folder_name());
            
            nums = str2double(jobID(end:end));
            nm = nums+1;
            assertEqual(name,['test_next_job1_id_num_',num2str(nm)]);
        end
        %
        function test_next_job_id_no_num(~)
            mf = MessagesFilebased();
            mf.job_id = 'test_next_job_nonum';
            clObj = onCleanup(@()finalize_all(mf));
            
            [~,name] = fileparts(mf.next_message_folder_name());
            
            non_num =  regexp(name,'\D');
            head = name(non_num );
            
            assertEqual(head ,'test_next_job_nonum_');
            
            tail = name(numel(head)+1:end);
            digit_pos = regexp(tail,'\d');
            
            assertEqual(1:numel(digit_pos),digit_pos)
        end
        
    end
end
