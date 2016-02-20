classdef test_MessageFramework< TestCase
    %
    % $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
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
        
        
    end
end

