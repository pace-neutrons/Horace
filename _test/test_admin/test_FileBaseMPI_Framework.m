classdef test_FileBaseMPI_Framework< TestCase
    %
    % $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_FileBaseMPI_Framework(name)
            if ~exist('name','var')
                name = 'test_FileBaseMPI_Framework';
            end
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        %
        function test_finalize_all(this)
            % not implemented
            mf = MFTester();
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
            mf = MFTester();
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
            
            mess = aMessage('starting');
            [ok,err] = mf.send_message(1,mess);
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            [ok,err] = mf.send_message(3,'started');
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            mess = aMessage('failed');
            [ok,err] = mf.send_message(4,mess);
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            
            mess = aMessage('blabla');
            [ok,err] = mf.send_message(5,mess);
            assertEqual(ok,MES_CODES.ok)
            assertTrue(isempty(err));
            
            %-------------------------------------------------------------
            all_mess = mf.probe_all(3);
            
            assertEqual(numel(all_mess),1);
            assertEqual(all_mess{1},'started');
            
            all_mess = mf.probe_all(2);
            assertEqual(numel(all_mess),1);
            assertTrue(isempty(all_mess{1}));
            
            all_mess = mf.probe_all([1,3,5]);
            
            assertEqual(numel(all_mess),3);
            assertEqual(all_mess{1},'starting');
            assertEqual(all_mess{2},'started');
            assertEqual(all_mess{3},'blabla');
            
            
            all_mess = mf.probe_all(1:4);
            
            assertEqual(numel(all_mess),4);
            assertEqual(all_mess{1},'starting');
            assertTrue(isempty(all_mess{2}));
            assertEqual(all_mess{3},'started');
            assertEqual(all_mess{4},'failed');
            
            
            all_mess = mf.probe_all([4,2]);
            assertEqual(numel(all_mess),2);
            assertEqual(all_mess{1},'failed');
            assertTrue(isempty(all_mess{2}));
            
            
            [all_mess,task_ids] = mf.probe_all();
            assertEqual(numel(all_mess),4);
            assertEqual(all_mess{1},'starting');
            assertEqual(task_ids(1),1);
            assertEqual(all_mess{2},'started');
            assertEqual(task_ids(2),3);
            assertEqual(all_mess{3},'failed');
            assertEqual(task_ids(3),4);
            assertEqual(all_mess{4},'blabla');
            assertEqual(task_ids(4),5);
            
            
        end
    end
end

