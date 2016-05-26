classdef test_MessageFramework< TestCase
    %
    % $Revision$ ($Date$)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_MessageFramework(name)
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        
        %
        function test_clear_messages(this)
            % not implemented
            mf = MFTester();
            [ok,err]=mf.send_message(1,'starting');
            assertTrue(ok)
            assertTrue(isempty(err));
            [ok,err]=mf.send_message(2,'starting');
            assertTrue(ok)
            assertTrue(isempty(err));
            
            ok=mf.check_message(1,'starting');
            assertTrue(ok)
            ok=mf.check_message(2,'starting');
            assertTrue(ok)
            
            mf.clear_all_messages();
            ok=mf.check_message(1,'starting');
            assertFalse(ok)
            ok=mf.check_message(2,'starting');
            assertFalse(ok)
            
        end
        
        function test_message(this)
            %
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            mess = aMessage('starting');
            mess.payload = job_param;
            mf = MFTester();
            [ok,err] = mf.send_message(1,mess);
            assertTrue(ok)
            assertTrue(isempty(err));
            
            mess_fname = mf.job_stat_fname(1,'starting');
            assertTrue(exist(mess_fname,'file')==2);
            %
            ok=mf.check_message(1,'starting');
            assertTrue(ok)
            
            [ok,err,the_mess]=mf.receive_message(1,'running');
            assertFalse(ok)
            assertFalse(isempty(err));
            assertTrue(isempty(the_mess));
            
            [ok,err,the_mess]=mf.receive_message(1,'starting');
            assertTrue(ok)
            assertTrue(isempty(err));
            assertFalse(exist(mess_fname,'file')==2);
            cont = the_mess.payload;
            
            assertEqual(job_param,cont);
            ok=mf.check_message(1,'starting');
            assertFalse(ok)
            
            mf.clear_all_messages();
        end
        function test_receive_all_mess(this)
            mf = MessagesFramework('MFT_receive_messages');
            clob = onCleanup(@()(mf.clear_all_messages()));
            
            mess = aMessage('starting');
            [ok,err] = mf.send_message(2,mess);
            assertTrue(ok)
            assertTrue(isempty(err));
            [messo,job_id] = mf.receive_all_messages(1:2);
            
            assertEqual(numel(messo),1);
            assertEqual(numel(job_id),1);
            assertEqual(job_id(1),2);
            assertEqual(messo{1}.mess_name,'starting')
            
            ok = mf.send_message(3,mess);
            assertTrue(ok)
            %
            [mess,job_id] = mf.receive_all_messages(3);
            assertEqual(numel(mess),1);
            assertEqual(numel(job_id),1);
            assertEqual(job_id(1),3);
            assertEqual(mess{1}.mess_name,'starting')
            %
            
            ok = mf.send_message(1,'started');
            assertTrue(ok)
            ok = mf.send_message(2,'started');
            assertTrue(ok)
            [mess,job_id] = mf.receive_all_messages(1:2);
            assertEqual(numel(mess),2);
            assertEqual(numel(job_id),2);
            assertEqual(job_id(1),1);
            assertEqual(job_id(2),2);
            
            
            
        end
        function test_list_messages(this)
            
            mf = MessagesFramework('MFT_list_messages');
            clob = onCleanup(@()(mf.clear_all_messages()));
            
            mess = aMessage('starting');
            [ok,err] = mf.send_message(1,mess);
            assertTrue(ok)
            assertTrue(isempty(err));
            [ok,err] = mf.send_message(3,'started');
            assertTrue(ok)
            assertTrue(isempty(err));
            mess = aMessage('failed');
            [ok,err] = mf.send_message(4,mess);
            assertTrue(ok)
            assertTrue(isempty(err));
            
            mess = aMessage('blabla');
            [ok,err] = mf.send_message(5,mess);
            assertTrue(ok)
            assertTrue(isempty(err));
            %-------------------------------------------------------------
            all_mess = mf.list_all_messages(3);
            
            assertEqual(numel(all_mess),1);
            assertEqual(all_mess{1},'started');
            
            all_mess = mf.list_all_messages(2);
            
            assertEqual(numel(all_mess),1);
            assertTrue(isempty(all_mess{1}));
            
            all_mess = mf.list_all_messages([1,3,5]);
            
            assertEqual(numel(all_mess),3);
            assertEqual(all_mess{1},'starting');
            assertEqual(all_mess{2},'started');
            assertEqual(all_mess{3},'blabla');
            
            
            all_mess = mf.list_all_messages(1:4);
            
            assertEqual(numel(all_mess),4);
            assertEqual(all_mess{1},'starting');
            assertTrue(isempty(all_mess{2}));
            assertEqual(all_mess{3},'started');
            assertEqual(all_mess{4},'failed');
            
            
            all_mess = mf.list_all_messages([4,2]);
            assertEqual(numel(all_mess),2);
            assertEqual(all_mess{1},'failed');
            assertTrue(isempty(all_mess{2}));
            
            
        end
        
        
        
    end
end

