classdef test_job_executor< TestCase
    %
    % $Revision$ ($Date$)
    %
    
    properties
        working_dir
    end
    methods
        %
        function this=test_job_executor(name)
            if ~exist('name','var')
                name = 'test_job_executor';
            end
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        
        function test_worker(this)
            mis = MPI_State.instance();
            mis.is_tested = true;
            clot = onCleanup(@()(setattr(mis,'is_deployed',false,'is_tested',false)));
            
            
            % build jobs data
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
            
            % initialize server side of the message framework, which will
            % drive job executor locally.
            mf = FilebasedMessages(struct('job_id','test_worker'));
            clo2 = onCleanup(@()(mf.finalize_all()));
            
            % Prepare control sequences for two jobs:
            % job 1
            info1 = mf.build_control(1);
            mess = aMessage('starting');
            mess.payload = cs1;
            [ok,err_mess]=mf.send_message(1,mess);
            assertEqual(ok,MES_CODES.ok,['Error: ',err_mess]);
            % job 2
            info2 = mf.build_control(2);
            mess.payload = cs2;
            [ok,err_mess]=mf.send_message(2,mess);
            assertEqual(ok,MES_CODES.ok,['Error: ',err_mess]);
            
            if verLessThan('matlab','8.1')
                if verLessThan('matlab','7.14')
                    warning('Signleton does not work properly on Maltab 2011a/b. not testing workers');
                    return
                elseif strcmpi(computer,'pcwin')
                    warning('Signleton does not work properly on Maltab 2012/b 32bit version. Not testing workers');
                    return
                end
            end
            
            % start two pseudo-independent client jobs
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
            
            [ok,err_mess,message] = mf.receive_message(1,'completed');
            assertEqual(ok,MES_CODES.ok,['Error: ',err_mess]);
            assertTrue(isempty(err_mess));
            
            assertEqual(message.mess_name,'completed')
            assertEqual(message.payload,'Job 1 generated 2 files')
            
            [ok,err_mess,message] = mf.receive_message(2,'completed');
            assertEqual(ok,MES_CODES.ok,['Error: ',err_mess]);
            
            assertEqual(message.mess_name,'completed')
            assertTrue(isempty(message.payload))
            
            mf.finalize_all();
            
        end
        
        
        function test_do_job(this)
            % Its a self test of the JETester to be sure its do_job is fine
            % not testing anything but JETester
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            control_struct = struct('loop_param',[],'n_steps',1,...
                'return_results',true);
            control_struct.loop_param = job_param;
            
            je = JETester();
            
            je=je.do_job(control_struct );
            assertTrue(exist(fullfile(this.working_dir,'test_jobDispatcher0_nf1.txt'),'file')==2);
            delete(fullfile(this.working_dir,'test_jobDispatcher0_nf1.txt'));
            
            assertFalse(isempty(je.task_outputs));
            assertEqual(je.task_outputs,'Job 0 generated 1 files')
            
        end
        
        
    end
end

