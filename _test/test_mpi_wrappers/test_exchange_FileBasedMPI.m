classdef test_exchange_FileBasedMPI < exchange_common_tests
    
    properties
    end
    methods
        %
        function obj = test_exchange_FileBasedMPI(name)
            if ~exist('name', 'var')
                name = 'test_exchange_FileBasedMPI';
            end
            cs  = iMessagesFramework.build_worker_init(tmp_dir, ...
                    'test_FB_message', 'MessagesFilebased', 1, 3,'test_mode');

            obj = obj@exchange_common_tests(name,...
                'MessagesFileBasedMPI_mirror_tester','herbert',cs);
            
            
        end
        %
        function test_finalize_all(~)
            mf = MFTester('test_finalize_all');
            [ok, err] = mf.send_message(0, 'starting');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            [ok, err] = mf.send_message(0, LogMessage());
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            %
            ok = mf.receive_message(0, 'starting');
            assertEqual(ok, MESS_CODES.ok)
            ok = mf.receive_message(0, 'log');
            assertEqual(ok, MESS_CODES.ok)
            
            
            [all_messages_names, task_ids] = mf.probe_all(0, 'log');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            %
            
            
            ok = mf.is_job_canceled();
            assertFalse(ok);
            mf.finalize_all();
            ok = mf.is_job_canceled();
            assertTrue(ok);
        end
        %
        function test_message(this)
            fiis = iMessagesFramework.build_worker_init(this.working_dir, ...
                'test_message', 'MessagesFilebased', 0, 3);
            fii = iMessagesFramework.deserialize_par(fiis);
            
            %
            job_param = struct('filepath', this.working_dir, ...
                'filename_template', 'test_jobDispatcher%d_nf%d.txt');
            
            mess = aMessage('starting');
            mess.payload = job_param;
            
            mf0 = MFTester(fii);
            clob = onCleanup(@()mf0.finalize_all());
            [ok, err] = mf0.send_message(1, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess_fname = mf0.mess_file_name(1, 'starting');
            assertTrue(exist(mess_fname, 'file') == 2);
            %
            fii.labID = 1;
            mf1 = MFTester(fii);
            [ok, err, the_mess] = mf1.receive_message(0, 'starting');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(exist(mess_fname, 'file') == 2); % Message received
            
            cont = the_mess.payload;
            assertEqual(job_param,cont);
            
            init_mess = InitMessage('some init info');
            [ok,err] = mf0.send_message(1,init_mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok,err,the_mess]=mf1.receive_message(0,'init');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(the_mess.payload.common_data,'some init info');
            
            
            
            [all_messages_names,task_ids] = mf1.probe_all(0,'log');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            
            
            job_exchange_folder = fileparts(mess_fname);
            assertTrue(exist(job_exchange_folder, 'dir') == 7)
            mf0.finalize_all();
            assertFalse(exist(job_exchange_folder, 'dir') == 7)
        end
        %
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
            
            
            mess = aMessage('starting');
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
            %
            [mess, task_id] = mf3.receive_all(0, 'starting');
            assertEqual(numel(mess), 1);
            assertEqual(numel(task_id), 1);
            assertEqual(task_id(1), 0);
            assertEqual(mess{1}.mess_name, 'starting')
            %
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
        %
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
            
            
            mess = aMessage('starting');
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
            
            [all_mess, mid_from] = m_host.probe_all(3);
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
            
            %
            [all_mess, id_from] = m_host.probe_all();
            
            % failed overwrites log despite log send later 
            assertEqual(numel(all_mess), 1);
            assertEqual(all_mess{1}, 'failed');            
            assertEqual(id_from(1), 3);
            
        end
        
        function lock_file = build_fake_lock(~, mf, mess_name)
            mess_file = mf.mess_file_name(0, mess_name);
            [fp, fn] = fileparts(mess_file);
            lock_file = fullfile(fp, [fn, '.lockw']);
            fh = fopen(lock_file, 'w');
            fclose(fh);
        end
        
        function test_ignore_locked(this)
            % test verifies that filebased messages which have lock are not
            % observed by the system until unlocked.
            function del_file(fname)
                if exist(fname, 'file') == 2
                    delete(fname);
                end
            end
            mf = MessagesFilebased('MFT_ignore_locked_messages');
            clob = onCleanup(@()(mf.finalize_all()));
            
            all_mess = mf.probe_all(1);
            assertTrue(isempty(all_mess));
            
            
            mess = aMessage('starting');
            % send message to itself
            [ok, err] = mf.send_message(0, mess);
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            [all_mess, mid_from] = mf.probe_all();
            assertTrue(ismember('starting', all_mess))
            assertFalse(ismember('started', all_mess))
            assertEqual(mid_from, 0);
            lock_starting = this.build_fake_lock(mf, 'starting');
            clob_lock1 = onCleanup(@()del_file(lock_starting));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            
            % send another message to itself
            [ok, err] = mf.send_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [all_mess, mid_from] = mf.probe_all();
            assertTrue(ismember('started', all_mess))
            assertEqual(mid_from, 0);
            
            % create fake lock:
            lock_started = this.build_fake_lock(mf, 'started');
            clob_lock2 = onCleanup(@()del_file(lock_started));
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            % create just lock (no file yet)
            lock_running = this.build_fake_lock(mf, 'log');
            clob_lock3 = onCleanup(@()del_file(lock_running));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));
            
            
            delete(lock_starting);
            
            all_mess = mf.probe_all();
            assertTrue(ismember('starting', all_mess))
            assertEqual(mid_from, 0);
            
            delete(lock_started);
            
            all_mess = mf.probe_all();
            assertEqual(numel(all_mess), 1);
            % receved the most recent  message 
            [ok, err] = mf.receive_message(0, 'started');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            all_mess = mf.probe_all();
            assertEqual(numel(all_mess), 1);
            
            [ok, err] = mf.receive_message(0, 'starting');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            all_mess = mf.probe_all();
            assertTrue(isempty(all_mess));                        
        end
        %
        function test_shared_folder(this)
            mf = MessagesFilebased();
            mf.mess_exchange_folder = this.working_dir;
            mf = mf.init_framework('test_shared_folder');
            clob = onCleanup(@()mf.finalize_all());
            
            cfn = config_store.instance().config_folder_name;
            jfn = fullfile(this.working_dir, cfn, mf.exchange_folder_name, mf.job_id);
            assertEqual(exist(jfn, 'dir'), 7);
            
            [ok, err] = mf.send_message(0, 'starting');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok, err, the_mess] = mf.receive_message(0, 'starting');
            assertEqual(ok, MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(the_mess.mess_name, 'starting');
            
            clear clob;
            assertTrue(exist(jfn, 'dir') == 0);
        end
        %
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
        function test_barrier_fail(this)
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
            [ok, err] = fbMPI2.send_message(1, FailedMessage('failed'));
            assertEqual(ok, MESS_CODES.ok, err)
            
            
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
            
            [ok, err, mess] = fbMPI1.receive_message(3, 'barrier');
            assertEqual(ok, MESS_CODES.ok, err)
            assertEqual(mess.mess_name, 'barrier');
            
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
        function test_transfer_init_and_config(obj, varargin)
            
            if nargin > 1
                obj.setUp();
                clob1 = onCleanup(@()tearDown(obj));
            end
            
            % testing the transfer of the initial information for a Herbert
            % job through a data exchange folder
            %
            % Prepare current configuration to be able to restore it after
            % the test finishes
            
            % set up basic default configuration
            pc = parallel_config;
            pc.saveable = false;
            cur_data = pc.get_data_to_store();
            clobC = onCleanup(@()set(pc, cur_data));
            % creates working directory
            pc.working_directory = fullfile(obj.working_dir, 'some_irrelevant_folder_never_used_here');
            wkdir0 = pc.working_directory;
            clobW = onCleanup(@()rmdir(wkdir0, 's'));
            
            %--------------------------------------------------------------
            % check the case when local file system and remote file system
            % coincide
            
            pc.shared_folder_on_remote = '';
            pc.shared_folder_on_local = '';
            
            % test structure to send
            % store configuration in a local config folder as local and
            % remote jobs have the same file system
            mpi = MessagesFilebased('testiMPI_transferInit');
            mpi.mess_exchange_folder = obj.working_dir;
            clob0 = onCleanup(@()finalize_all(mpi));
            % the operation above copies config files to the folder
            % calculated by assign operation
            config_exchange = fileparts(fileparts(mpi.mess_exchange_folder));
            assertTrue(exist(fullfile(config_exchange, 'herbert_config.mat'), 'file') == 2);
            
            jt = JETester();
            initMess = jt.get_worker_init();
            assertTrue(isa(initMess, 'aMessage'));
            data = initMess.payload;
            assertTrue(data.exit_on_compl);
            assertFalse(data.keep_worker_running);
            
            % simulate the configuration operations happening on a remote machine side
            mis = MPI_State.instance();
            mis.is_deployed = true;
            mis.is_tested = true;
            clob4 = onCleanup(@()set(mis, 'is_deployed', false, 'is_tested', false));
            % the filesystem is shared so working_directory is used as
            % shared folder
            wk_dir = fullfile(obj.working_dir, 'some_irrelevant_folder_never_used_here');
            assertEqual(pc.working_directory, wk_dir);
            assertEqual(pc.shared_folder_on_local, wk_dir);
            assertEqual(pc.shared_folder_on_remote, wk_dir);
            
            
            %--------------------------------------------------------------
            %now test storing/restoring project configuration from a
            %directory different from default.
            mis.is_deployed = false;
            pc.shared_folder_on_local = obj.working_dir;
            assertEqual(pc.working_directory, wk_dir);
            assertEqual(pc.shared_folder_on_local, obj.working_dir);
            assertEqual(pc.shared_folder_on_remote, obj.working_dir);
            
            
            %-------------------------------------------------------------
            % ensure default configuration location will be restored after
            % the test
            clob5 = onCleanup(@()config_store.instance('clear'));
            %
            cfn = config_store.instance().config_folder_name;
            remote_config_folder = fullfile(pc.shared_folder_on_remote, ...
                cfn);
            clob6 = onCleanup(@()rmdir(remote_config_folder, 's'));
            % remove all configurations from memory to ensure they would be
            % read from non-default locations.
            config_store.instance('clear');
            
            % these operations would happen on worker
            mis.is_deployed = true;
            config_store.set_config_folder(remote_config_folder)
            
            % on a deployed program working directory coincides with shared_folder_on_remote
            pc = parallel_config;
            assertEqual(pc.working_directory, pc.shared_folder_on_remote);
            
            
            r_config_folder = config_store.instance().config_folder;
            assertEqual(r_config_folder, remote_config_folder);
        end
    end
end
