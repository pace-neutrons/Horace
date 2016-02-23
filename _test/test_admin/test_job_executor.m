classdef test_job_executor< TestCase
    %
    % $Revision: 278 $ ($Date: 2013-11-01 20:07:58 +0000 (Fri, 01 Nov 2013) $)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_job_executor(name)
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        
        function test_worker(this)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));

           
            
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            
            job_contr = struct('loop_param',[],'n_steps',1,...
                'return_results',true);
            cs1 = job_contr;
            cs1.loop_param = [job_param,job_param];
            cs1.n_steps = 2;
            
            cs2 = job_contr;
            cs2.loop_param = job_param;
            cs2.return_results = false;
            
            je = MessagesFramework('test_worker');
            info1 = je.init_worker_control(1);
            mess = aMessage('starting');
            mess.payload = cs1;
            [ok,err_mess]=je.send_message(1,mess);
            assertTrue(ok);
            assertTrue(isempty(err_mess));
            
            info2 = je.init_worker_control(2);
            mess.payload = cs2;
            [ok,err_mess]=je.send_message(2,mess);
            assertTrue(ok);
            assertTrue(isempty(err_mess));
            
            
            worker('JETester',info1);
            worker('JETester',info2);
            
            
            file1= fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            file1a= fullfile(this.working_dir,'test_jobDispatcher1_nf2.txt');
            
            file2= fullfile(this.working_dir,'test_jobDispatcher2_nf1.txt');
            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file1a,'file')==2);
            assertTrue(exist(file2,'file')==2);
            delete(file1);
            delete(file1a);
            delete(file2);
            
            [ok,err_mess,message] = je.receive_message(1,'completed');
            assertTrue(ok);
            assertTrue(isempty(err_mess));
            
            assertEqual(message.mess_name,'completed')
            assertEqual(message.payload,'Job 1 generated 2 files')
            
            [ok,err_mess,message] = je.receive_message(2,'completed');
            assertTrue(ok);
            assertTrue(isempty(err_mess));
            
            assertEqual(message.mess_name,'completed')
            assertTrue(isempty(message.payload))
            
            je.clear_all_messages();
            
        end
        
        
        function test_do_job(this)
            % Its a self test to be sure do_job is fine
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            control_struct = struct('loop_param',[],'n_steps',1,...
                'return_results',true);
            control_struct.loop_param = job_param;
            
            je = JETester();
            
            je=je.do_job(control_struct );
            assertTrue(exist(fullfile(this.working_dir,'test_jobDispatcher0_nf1.txt'),'file')==2);
            delete(fullfile(this.working_dir,'test_jobDispatcher0_nf1.txt'));
            
            assertFalse(isempty(je.job_outputs));
            assertEqual(je.job_outputs,'Job 0 generated 1 files')
            
            je.clear_all_messages();
        end
        
        
    end
end

