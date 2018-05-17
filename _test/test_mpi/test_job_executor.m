classdef test_job_executor< TestCase
    %
    % $Revision: 702 $ ($Date: 2018-02-12 19:05:22 +0000 (Mon, 12 Feb 2018) $)
    %
    
    properties
        working_dir;
        current_config_folder;
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
            common_job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            
            %cs  = iMessagesFramework.deserialize_par(css1);
            % initiate exchange class which would work on a client(worker's) side
            serverfbMPI  = MessagesFilebased('test_worker');
            serverfbMPI.mess_exchange_folder = this.working_dir;
            %             cs.labID = 0;
            %             serverfbMPI= serverfbMPI.init_framework(cs);
            clob = onCleanup(@()finalize_all(serverfbMPI));
            css1= serverfbMPI.gen_worker_init(1,2);
            css2= serverfbMPI.gen_worker_init(2,2);
            
            
            je_initMess = serverfbMPI.build_je_init('JETester');
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
                    warning('Signleton does not work properly on Maltab 2011a/b. not testing workers');
                    return
                elseif strcmpi(computer,'pcwin')
                    warning('Signleton does not work properly on Maltab 2012/b 32bit version. Not testing workers');
                    return
                end
            end
            % workers change config folder to its own value so ensure it
            % will be reverted to the initial value
            cs = config_store.instance();
            this.current_config_folder = cs.config_folder;
            clob1 = onCleanup(@()(set_config_path(cs,this.current_config_folder)));

            file1= fullfile(this.working_dir,'test_jobDispatcher1_nf1.txt');
            file1a= fullfile(this.working_dir,'test_jobDispatcher1_nf2.txt');
            
            file2= fullfile(this.working_dir,'test_jobDispatcher2_nf1.txt');
            clob2 = onCleanup(@()delete(file1,file1a,file2));
            
            
            % start two client jobs
            % second needs to start first as it will report its profess to
            % the lab1
            worker(css2);
            worker(css1);
            % all workers reply 'started' to headnode as it is cluster
            % control message
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'started')            
            [ok,err_mess,message] = serverfbMPI.receive_message(2,'started');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertEqual(message.mess_name,'started')            

            
            assertTrue(exist(file1,'file')==2);
            assertTrue(exist(file1a,'file')==2);
            assertTrue(exist(file2,'file')==2);
            
            [ok,err_mess,message] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,['Error: ',err_mess]);
            assertTrue(isempty(err_mess));
            
            assertEqual(message.mess_name,'completed')
            assertEqual(message.payload{1},'Job 1 generated 2 files')
            assertEqual(message.payload{2},'Job 2 generated 1 files')
            
            
        end
        
        
        function test_do_job(this)
            % Its a self test of the JETester to be sure its do_job is fine
            % not testing anything but JETester
            common_job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcher%d_nf%d.txt');
            initMess = InitMessage(common_job_param,1,true);
            css = iMessagesFramework.build_worker_init(this.working_dir,'test_do_job',1,1);
            cs  = iMessagesFramework.deserialize_par(css);
            % initiate exchange class which would work on a client(worker's) side
            fbMPI = MessagesFilebased();
            fbMPI = fbMPI.init_framework(cs);
            clob = onCleanup(@()finalize_all(fbMPI));
            
            % initiate exchange class which would work on the server's side
            cs.labID = 0;
            serverfbMPI  = MessagesFilebased(cs);
            
            % initate job executor would working on a client side.
            je = JETester();
            je = je.init(fbMPI,cs,initMess);
            
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
            assertTrue(exist(job_result_file,'file')==2);
            
            
            assertFalse(isempty(je.task_outputs));
            assertEqual(je.task_outputs,'Job 1 generated 1 files')
            
            % finalize the job run on worker and return final results
            [ok,mess] =je.finish_task();
            assertTrue(ok);
            assertTrue(isempty(mess));
            
            % receive the final results on the server and verify their
            % correctness.
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok);
            assertTrue(isempty(err));
            assertEqual(je.task_outputs,mess.payload{1})
        end
        
        
    end
end

