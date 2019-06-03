classdef test_job_dispatcher_parpool< job_dispatcher_common_tests
    % Test running using the parpool job dispatcher.
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_job_dispatcher_parpool(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_parpool';
            end
            this = this@job_dispatcher_common_tests(name,'parpool');
        end
        %
        function test_finish_tasks_reduce_messages(obj,varargin)
            if obj.ignore_test
                return;
            end
            if nargin>1
                obj.setUp();
                clob0 = onCleanup(@()tearDown(obj));
            end
            
            serverfbMPI  = MessagesFilebased('test_finish_tasks_reduce_mess');
            serverfbMPI.mess_exchange_folder = obj.working_dir;
            
            clob = onCleanup(@()finalize_all(serverfbMPI));
            % generate 3 controls to have 3 filebased MPI pseudo-workers
            css1= serverfbMPI.gen_worker_init();
            
            cl = parcluster();
            num_labs = cl.NumWorkers;
            if num_labs < 4
                return;
            end
            num_labs = 4;
            pl = gcp('nocreate'); % Get the current parallel pool
            if isempty(pl) || pl.NumWorkers ~=num_labs
                delete(pl)
                pl = parpool(cl,num_labs);
            end
            
            spmd
                ok = finish_task_tester(css1);
            end
            
            
            assertEqual(numel(ok),num_labs);
            all_ok = arrayfun(@(x)(x{1}),ok,'UniformOutput',true);
            assertTrue(all(all_ok));
            [ok,err,mess] = serverfbMPI.receive_message(1,'started');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'started');
            [ok,err,mess] = serverfbMPI.receive_message(1,'completed');
            assertEqual(ok,MESS_CODES.ok,err);
            assertEqual(mess.mess_name,'completed');
            
        end
        function xest_job_submittion(obj)
            % test to debug job submission on cluster. It's not usually run
            % as all logic is tested elsewhere but kept to help identifying
            % the issues with job submission on a cluster.
            if obj.ignore_test
                return;
            end
            % delete interactive parallel cluster if any exist
            cl = gcp('nocreate');
            if ~isempty(cl)
                delete(cl);
            end
            
            cl  = parcluster();
            cjob = createCommunicatingJob(cl,'Type','SPMD');
            cjob.NumWorkersRange = 3;
            cjob.AutoAttachFiles = false;
            file1= 'test_file_Process1.txt';
            file2= 'test_file_Process2.txt';
            file3= 'test_file_Process3.txt';
            clob1 = onCleanup(@()delete(file1,file2,file3));
            
            function create_test_file(name)
                ind = labindex();
                fName = sprintf('test_file_Process%d.txt',ind);
                fh = fopen(fName,'w');
                clob = onCleanup(@()fclose(fh));
                fprintf(fh,'file created from process %d, Input: %s',ind,name);
            end
            task = createTask(cjob,@create_test_file,0,{'bla_bla'});
            submit(cjob);
            
            
            wait(cjob)
            assertTrue(exist(file1,'file') == 2);
            assertTrue(exist(file2,'file') == 2);
            assertTrue(exist(file3,'file') == 2);
            delete(cjob)
        end
        
        
    end
end

