classdef test_FileBaseMPI_Framework< TestCase
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    
    properties
        working_dir
        old_config
        % if default current framework is not a Herbert framework,
        % one need to change the setup
        change_setup = false;
    end
    methods
        %
        function this=test_FileBaseMPI_Framework(name)
            if ~exist('name','var')
                name = 'test_FileBaseMPI_Framework';
            end
            this = this@TestCase(name);
            this.working_dir = tempdir;
            pc = parallel_config;
            if strcmpi(pc.parallel_framework,'herbert')
                this.change_setup = false;
            else
                this.old_config = pc.get_data_to_store;
                pc.parallel_framework = 'herbert';
                this.change_setup = true;
            end
        end
        %
        function setUp(obj)
            if obj.change_setup
                pc = parallel_config;
                pc.parallel_framework = 'herbert';
            end
        end
        function teadDown(obj)
            if obj.change_setup
                set(parallel_config,obj.old_config);
            end
        end
        
        
        %
        function test_finalize_all(this)
            mf = MFTester('test_finalize_all');
            [ok,err]=mf.send_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [ok,err]=mf.send_message(0,'running');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            %
            ok=mf.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            ok = mf.receive_message(0,'running');
            assertEqual(ok,MESS_CODES.ok)
            
            
            [all_messages_names,task_ids] = mf.probe_all(0,'running');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            %
            
            
            ok = mf.is_job_cancelled();
            assertFalse(ok);
            mf.finalize_all();
            ok = mf.is_job_cancelled();
            assertTrue(ok);
        end
        %
        function test_message(this)
            fiis = iMessagesFramework.build_worker_init(this.working_dir,...
                'test_message',0,3);
            fii = iMessagesFramework.deserialize_par(fiis);
            
            %
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            mess = aMessage('starting');
            mess.payload = job_param;
            
            mf0 = MFTester(fii);
            clob = onCleanup(@()mf0.finalize_all());
            [ok,err] = mf0.send_message(1,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess_fname = mf0.mess_name(1,'starting');
            assertTrue(exist(mess_fname,'file')==2);
            %
            fii.labID = 1;
            mf1 = MFTester(fii);
            [ok,err,the_mess]=mf1.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(exist(mess_fname,'file')==2);% Message received
            
            cont = the_mess.payload;
            assertEqual(job_param,cont);
            
            [all_messages_names,task_ids] = mf1.probe_all(0,'running');
            assertTrue(isempty(all_messages_names));
            assertTrue(isempty(task_ids));
            
            
            job_exchange_folder = fileparts(mess_fname);
            assertTrue(exist(job_exchange_folder,'dir') == 7)
            mf0.finalize_all();
            assertFalse(exist(job_exchange_folder,'dir') == 7)
        end
        %
        function test_receive_all_mess(this)
            fiis = iMessagesFramework.build_worker_init(this.working_dir,...
                'FB_MPI_Test_recevie_all',0,3);
            fii = iMessagesFramework.deserialize_par(fiis);
            mf0 = MessagesFilebased(fii);
            
            clob = onCleanup(@()(mf0.finalize_all()));
            fii.labID = 1;
            mf1 = MessagesFilebased(fii);
            fii.labID = 2;
            mf2 = MessagesFilebased(fii);
            fii.labID = 3;
            mf3 = MessagesFilebased(fii);
            
            
            mess = aMessage('starting');
            [ok,err] = mf0.send_message(2,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [messo,task_id] = mf2.receive_all(0);
            
            assertEqual(numel(messo),1);
            assertEqual(numel(task_id),1);
            assertEqual(task_id(1),0);
            assertEqual(messo{1}.mess_name,'starting')
            
            ok = mf0.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            %
            [mess,task_id] = mf3.receive_all(0,'starting');
            assertEqual(numel(mess),1);
            assertEqual(numel(task_id),1);
            assertEqual(task_id(1),0);
            assertEqual(mess{1}.mess_name,'starting')
            %
            % Send 3 messages from "3 labs" and receive all of them
            % on the control lab
            ok = mf1.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            
            ok = mf2.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            
            ok = mf3.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            
            
            [mess,task_id] = mf0.receive_all();
            assertEqual(numel(mess),3);
            assertEqual(numel(task_id),3);
            assertEqual(task_id(1),1);
            assertEqual(task_id(2),2);
            assertEqual(task_id(3),3);
        end
        %
        function test_probe_all(this)
            mf = MessagesFilebased('MFT_probe_all_messages');
            clob = onCleanup(@()(mf.finalize_all()));
            
            all_mess = mf.probe_all(1);
            assertTrue(isempty(all_mess));
            
            
            mess = aMessage('starting');
            % send message to itself
            [ok,err] = mf.send_message(0,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            [all_mess,mid_from] = mf.probe_all();
            assertTrue(ismember('starting',all_mess))
            assertFalse(ismember('started',all_mess))
            assertEqual(mid_from,0);
            
            
            [all_mess,mid_from] = mf.probe_all(0);
            assertTrue(ismember('starting',all_mess))
            assertEqual(mid_from,0);
            [all_mess,mid_from] = mf.probe_all(0,'starting');
            assertTrue(ismember('starting',all_mess))
            assertEqual(mid_from,0);
            
            
            
            [ok,err] = mf.send_message(0,'started');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            mess = aMessage('failed');
            [ok,err] = mf.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            mess = aMessage('running');
            [ok,err] = mf.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [all_mess,mid_from] = mf.probe_all(0);
            assertEqual(numel(all_mess),2);
            assertEqual(all_mess{1},'started');
            assertEqual(mid_from(1),0);
            assertEqual(mid_from(2),0);
            
            %
            %-------------------------------------------------------------
            % define external receiver, which would run on an MPI worker
            cs = mf.build_worker_init(mf.mess_exchange_folder,mf.job_id,3,5);
            
            init_str = mf.deserialize_par(cs);
            mf3 = MessagesFilebased(init_str);
            [all_mess,id_from] = mf3.probe_all();
            
            
            assertEqual(numel(all_mess),2);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            
            mess = aMessage('running');
            % unlike normal mpi, filebased mpi allows sending message to
            % itself
            [ok,err] = mf3.send_message(3,mess);
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            
            [all_mess,id_from] = mf3.probe_all();
            assertEqual(numel(all_mess),3);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            assertEqual(id_from(3),3);
            
            
            [all_mess,id_from] = mf3.probe_all([0,3]);
            assertEqual(numel(all_mess),3);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),0);
            assertEqual(id_from(3),3);
            
            [all_mess,id_from] = mf3.probe_all('all','running');
            assertEqual(numel(all_mess),2);
            assertEqual(id_from(1),0);
            assertEqual(id_from(2),3);
        end
        function test_shared_folder(this)
            mf = MessagesFilebased();
            mf.mess_exchange_folder = this.working_dir;
            mf = mf.init_framework('test_shared_folder');
            clob = onCleanup(@()mf.finalize_all());
            
            jfn = fullfile(this.working_dir,config_store.config_folder_name,mf.exchange_folder_name,mf.job_id);
            assertEqual(exist(jfn,'dir'),7);
            
            [ok,err] = mf.send_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            
            [ok,err,the_mess] = mf.receive_message(0,'starting');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(the_mess.mess_name,'starting');
            
            clear clob;
            assertTrue(exist(jfn,'dir')==0);
        end
        
        function test_barrier(this)
            mf = MessagesFilebased('test_barrier');
            mf.mess_exchange_folder = this.working_dir;
            clob = onCleanup(@()mf.finalize_all());
            % create three pseudo-independent message exchange classes
            % presumably to run on independent workers
            css1 = iMessagesFramework.build_worker_init(this.working_dir,mf.job_id,1,3);
            cs1  = iMessagesFramework.deserialize_par(css1);
            css2 = iMessagesFramework.build_worker_init(this.working_dir,mf.job_id,2,3);
            cs2  = iMessagesFramework.deserialize_par(css2);
            css3 = iMessagesFramework.build_worker_init(this.working_dir,mf.job_id,3,3);
            cs3 =  iMessagesFramework.deserialize_par(css3);
            
            fbMPI1 = MessagesFilebased(cs1);
            fbMPI2 = MessagesFilebased(cs2);
            fbMPI3 = MessagesFilebased(cs3);
            
            t0 = fbMPI3.time_to_fail;
            fbMPI3.time_to_fail = 0.1;
            % barrier fails at waiting time due to short time to fail
            try
                fbMPI3.labBarrier();
            catch ME
                assertEqual(ME.message,...
                    'Timeout waiting for message "barrier" for task with id: 3');
            end
            fbMPI2.time_to_fail = 0.1;
            try
                fbMPI2.labBarrier();
            catch ME
                assertEqual(ME.message,...
                    'Timeout waiting for message "barrier" for task with id: 2');
            end
            
            fbMPI3.time_to_fail = t0;
            fbMPI2.time_to_fail = t0;
            
            
            % will pass without delay as all other worker would reach the
            % barrier
            ok = fbMPI1.labBarrier();
            assertTrue(ok);
            
            % and other workers would pass barrier now
            ok = fbMPI3.labBarrier();
            assertTrue(ok);
            ok = fbMPI2.labBarrier();
            assertTrue(ok);
            
            % clear up the barrier messages
            [ok,err,mess] = fbMPI1.receive_message(2,'barrier');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'barrier');
            
            [ok,err,mess] = fbMPI1.receive_message(3,'barrier');
            assertEqual(ok,MESS_CODES.ok)
            assertTrue(isempty(err));
            assertEqual(mess.mess_name,'barrier');
            
        end
    end
end

