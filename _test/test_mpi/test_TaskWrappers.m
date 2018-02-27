classdef test_TaskWrappers < TestCase
    properties
        working_dir
    end
    methods
        %
        function this=test_TaskWrappers(name)
            if ~exist('name','var')
                name = 'test_TaskWrappers';
            end
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        function test_ParpoolTaskWrapper(this)
            % ignore this test if parallel computing toolbox is not
            % available
            if ~license('checkout','Distrib_Computing_Toolbox')
                return;
            end
            %
            mpi = FilebasedMessages('test_ParpoolTaskWrapper');
            clob = onCleanup(@()(mpi.finalize_all()));

            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            task_inputs = struct('loop_param',[],'n_steps',3,...
                'return_results',false);
            task_inputs.loop_param =[job_param,job_param,job_param];
            
            
            ts = ParpoolTaskWrapper();
            ts = ts.start_task(mpi,'JETester',1,task_inputs);
            [ok,fail,err_mess] = ts.is_running();
            assertTrue(ok)
            assertFalse(fail);
            assertTrue(isempty(err_mess));
            ts = ts.stop_task();
            [ok,fail,err_mess] = ts.is_running();
            assertFalse(ok);
            assertTrue(fail);
            assertEqual(err_mess,'process has not been started');            
        end
        
        
        
        function test_JavaTaskWrapper(this)
            mpi = FilebasedMessages('test_JavaTaskWrapper');
            clob = onCleanup(@()(mpi.finalize_all()));
            %contr = mpi.build_control(1);
            job_param = struct('filepath',this.working_dir,...
                'filename_template','test_jobDispatcherL%d_nf%d.txt');
            
            task_inputs = struct('loop_param',[],'n_steps',3,...
                'return_results',false);
            task_inputs.loop_param =[job_param,job_param,job_param];
            
            
            ts = JavaTaskWrapper();
            ts = ts.start_task(mpi,'JETester',1,task_inputs);
            [ok,fail,err_mess] = ts.is_running();
            assertTrue(ok)
            assertFalse(fail);
            assertTrue(isempty(err_mess));
            ts = ts.stop_task();
            [ok,fail,err_mess] = ts.is_running();
            assertFalse(ok);
            assertTrue(fail);
            assertEqual(err_mess,'process has not been started');            
        end
        
        
        
    end
end
