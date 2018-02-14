classdef test_taskController < TestCase
    properties
        working_dir
    end
    methods
        %
        function this=test_taskController(name)
            if ~exist('name','var')
                name = 'test_taskController';
            end
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        
        
        function test_task_progress(this)
            mpi = FilebasedMessages('TJC_test_task_progres');
            clob = onCleanup(@()(mpi.finalize_all()));
            
            % this sets up failing on 3 attempts to verify task status
            mpi.time_to_fail=mpi.tasks_check_time;
            
            tc = taskController(3);
            [tc,is_running] = tc.check_and_set_task_state(mpi,'starting');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,1);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,'starting');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,2);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,'starting');
            assertFalse(is_running);
            assertEqual(tc.waiting_count,3);
            assertTrue(tc.is_failed);
            %
            
            ok = mpi.send_message(3,'started');
            assertTrue(ok);
            % check recovery from failed state
            [tc,is_running] = tc.check_and_set_task_state(mpi,'started');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,0);
            assertFalse(tc.is_failed);
            assertTrue(tc.is_running);
            assertFalse(tc.reports_progress);
            %
            % Fail on receiving no message three times in a row
            [tc,is_running] = tc.check_and_set_task_state(mpi,'');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,1);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,[]);
            assertTrue(is_running);
            assertEqual(tc.waiting_count,2);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,[]);
            assertFalse(is_running);
            assertEqual(tc.waiting_count,3);
            assertTrue(tc.is_failed);
            
            % receive and discard 'started' message
            ok = mpi.receive_message(3,'started');
            assertTrue(ok);
            % send log message instead
            mess = LogMessage(1,10,0.0,'bla bla bla');
            ok = mpi.send_message(3,mess);
            assertTrue(ok);
            
            % check recovery from failed state
            [tc,is_running] = tc.check_and_set_task_state(mpi,mess.mess_name);
            assertTrue(is_running);
            assertEqual(tc.waiting_count,0);
            assertFalse(tc.is_failed);
            assertTrue(tc.is_running);
            assertTrue(tc.reports_progress);
            
            % Check never fails on waiting as waiting time is 0
            ok = mpi.check_message(3,'running');
            assertFalse(ok);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,'running');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,0);
            assertFalse(tc.is_failed);
            assertTrue(tc.is_running);
            assertTrue(tc.reports_progress);
            
            % never fails on time-out as waiting time is 0
            [tc,is_running] = tc.check_and_set_task_state(mpi,'');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,0);
            assertFalse(tc.is_failed);
            assertTrue(tc.is_running);
            assertTrue(tc.reports_progress);
            
            % send message with timing and fail on time-out
            mess = LogMessage(1,10,0.01,'bla bla bla');
            ok = mpi.send_message(3,mess);
            assertTrue(ok);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,'running');
            assertTrue(is_running);
            assertEqual(tc.waiting_count,0);
            assertFalse(tc.is_failed);
            assertTrue(tc.is_running);
            assertTrue(tc.reports_progress);
            
            pause(0.2);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,'');
            assertFalse(is_running);
            assertEqual(tc.waiting_count,0);
            assertTrue(tc.is_failed);
            assertFalse(tc.is_running);
            assertTrue(tc.reports_progress);
            
            % recover on getting completed message
            mess = aMessage('completed');
            mess.payload = 'dummy task output';
            ok = mpi.send_message(3,mess);
            assertTrue(ok);
            
            [tc,is_running] = tc.check_and_set_task_state(mpi,'completed');
            assertFalse(is_running);
            assertEqual(tc.waiting_count,0);
            assertFalse(tc.is_failed);
            assertFalse(tc.is_running);
            assertTrue(tc.is_finished);
            assertTrue(tc.reports_progress);
            assertEqual(tc.outputs,'dummy task output');
            
            ok = mpi.check_message(3,'completed');
            assertFalse(ok);
            
            % fail will even kill completed, though it should not ever
            % happen, though output still exist
            ok = mpi.send_message(3,'failed');
            assertTrue(ok);
            [tc,is_running] = tc.check_and_set_task_state(mpi,'failed');
            assertFalse(is_running);
            assertTrue(tc.is_failed);
            assertTrue(isempty(tc.fail_reason));
            assertEqual(tc.outputs,'dummy task output');
        end
        
        function test_log(this)
            jc = taskController(2);
            log = jc.get_task_info();
            assertEqual(log,'taskN:02| starting |')
        end
        
    end
end
