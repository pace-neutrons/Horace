classdef test_FileBaseMPI_Framework< TestCase
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    
    properties
        working_dir
        old_config
        % if default current framework is not a herbert framework,
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
            % not implemented
            mf = MFTester('test_finalize_all');
            [ok,err]=mf.send_message(1,'starting');
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            [ok,err]=mf.send_message(2,'starting');
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            %
            ok=mf.receive_message(1,'starting');
            assertEqual(ok,MES_CODES.ok)
            ok = mf.receive_message(2,'starting');
            assertEqual(ok,MES_CODES.ok)
            
            %
            ok=mf.receive_message(1,'starting');
            assertEqual(ok,MES_CODES.not_exist)
            ok=mf.receive_message(2,'starting');
            assertEqual(ok,MES_CODES.not_exist)
            
            
            ok = mf.is_job_cancelled();
            assertFalse(ok);
            mf.finalize_all();
            ok = mf.is_job_cancelled();
            assertTrue(ok);
        end
        %
        function test_message(this)
            %
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            mess = aMessage('starting');
            mess.payload = job_param;
            mf = MFTester('test_message');
            clob = onCleanup(@()mf.finalize_all());
            [ok,err] = mf.send_message(1,mess);
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            
            mess_fname = mf.mess_name(1,'starting');
            assertTrue(exist(mess_fname,'file')==2);
            %
            [ok,err,the_mess]=mf.receive_message(1,'starting');
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            assertFalse(exist(mess_fname,'file')==2);% Message received
            
            cont = the_mess.payload;
            assertEqual(job_param,cont);
            
            
            [ok,err,the_mess]=mf.receive_message(1,'running');
            assertEqual(ok,MES_CODES.not_exist)
            assertFalse(isempty(err));
            assertTrue(isempty(the_mess));
            
            
            job_exchange_folder = fileparts(mess_fname);
            assertTrue(exist(job_exchange_folder,'dir') == 7)
            mf.finalize_all();
            assertFalse(exist(job_exchange_folder,'dir') == 7)
        end
        %
        function test_receive_all_mess(this)
            mf = FilebasedMessages('MFT_receive_messages');
            clob = onCleanup(@()(mf.finalize_all()));
            
            mess = aMessage('starting');
            [ok,err] = mf.send_message(2,mess);
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            [messo,task_id] = mf.receive_all_messages(1:2);
            
            assertEqual(numel(messo),1);
            assertEqual(numel(task_id),1);
            assertEqual(task_id(1),2);
            assertEqual(messo{1}.mess_name,'starting')
            
            ok = mf.send_message(3,mess);
            assertEqual(ok,MES_CODES.ok)
            %
            [mess,task_id] = mf.receive_all_messages(3);
            assertEqual(numel(mess),1);
            assertEqual(numel(task_id),1);
            assertEqual(task_id(1),3);
            assertEqual(mess{1}.mess_name,'starting')
            %
            
            ok = mf.send_message(1,'started');
            assertEqual(ok,MES_CODES.ok)
            
            ok = mf.send_message(2,'started');
            assertEqual(ok,MES_CODES.ok)
            
            [mess,task_id] = mf.receive_all_messages(1:2);
            assertEqual(numel(mess),2);
            assertEqual(numel(task_id),2);
            assertEqual(task_id(1),1);
            assertEqual(task_id(2),2);
            
            
            ok = mf.send_message(1,'running');
            assertEqual(ok,MES_CODES.ok)
            ok = mf.send_message(2,'rubbish');
            assertEqual(ok,MES_CODES.ok)
            ok = mf.send_message(2,'blah');
            assertEqual(ok,MES_CODES.ok)
            
            mes_st = warning('off','FILEBASED_MESSAGES:invalid_message');
            clob1 = onCleanup(@()warning(mes_st));
            [mess,task_id] = mf.receive_all_messages();
            assertEqual(numel(mess),2);
            assertEqual(numel(task_id),2);
            assertEqual(task_id(1),1);
            assertEqual(task_id(2),2);
            
            [mess,task_id] = mf.receive_all_messages();
            assertEqual(numel(mess),0);
            assertEqual(numel(task_id),0);
        end
        %
        function test_probe_all(this)
            mf = FilebasedMessages('MFT_probe_all_messages');
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
            cs = mf.build_framework_init(mf.mess_exchange_folder,mf.job_id,3,5);
            
            init_str = mf.deserialize_par(cs);
            mf3 = FilebasedMessages(init_str);
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
            mf = FilebasedMessages();
            mf.job_data_folder = this.working_dir;
            mf = mf.init_framework('test_shared_folder');
            clob = onCleanup(@()mf.finalize_all());
            
            jfn = fullfile(this.working_dir,mf.exchange_folder_name,mf.job_id);
            assertEqual(exist(jfn,'dir'),7);
            
            [ok,err] = mf.send_message(1,'starting');
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            
            [ok,err] = mf.receive_message(1,'starting');
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            
            clear clob;
            assertTrue(exist(jfn,'dir')==0);
        end
        
    end
end

