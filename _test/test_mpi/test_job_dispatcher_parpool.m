classdef test_job_dispatcher_parpool< job_dispatcher_common_tests
    % Test running using the parpool job dispatcher.
    %
    % $Revision$ ($Date$)
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
        
        
    end
end

