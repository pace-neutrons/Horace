classdef test_jobController < TestCase
    properties
        working_dir
    end
    methods
        %
        function this=test_jobController(name)
            this = this@TestCase(name);
            this.working_dir = tempdir;
        end
        
        
        function test_job_progress(this)
            mpi = JobDispatcher('TJC_test_job_progres');
            clob = onCleanup(@()(mpi.clear_all_messages()));
            
            % this sets up failing on 3 attempts to verify job status
            mpi.time_to_fail=mpi.jobs_check_time;
            
            jc = jobController(3);
            [jc,is_running] = jc.check_and_set_job_state(mpi,'starting');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,1);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,'starting');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,2);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,'starting');
            assertFalse(is_running);
            assertEqual(jc.waiting_count,3);
            assertTrue(jc.is_failed);
            %
            
            ok = mpi.send_message(3,'started');
            assertTrue(ok);
            % check recovery from failed state
            [jc,is_running] = jc.check_and_set_job_state(mpi,'started');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,0);
            assertFalse(jc.is_failed);
            assertTrue(jc.is_running);
            assertFalse(jc.reports_progress);
            %
            % Fail on receiving no message three times in a row
            [jc,is_running] = jc.check_and_set_job_state(mpi,'');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,1);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,[]);
            assertTrue(is_running);
            assertEqual(jc.waiting_count,2);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,[]);
            assertFalse(is_running);
            assertEqual(jc.waiting_count,3);
            assertTrue(jc.is_failed);
            
            % receive and discard 'started' message
            ok = mpi.receive_message(3,'started');
            assertTrue(ok);
            % send log message instead
            mess = LogMessage(1,10,0.0,'bla bla bla');
            ok = mpi.send_message(3,mess);
            assertTrue(ok);
            
            % check recovery from failed state
            [jc,is_running] = jc.check_and_set_job_state(mpi,mess.mess_name);
            assertTrue(is_running);
            assertEqual(jc.waiting_count,0);
            assertFalse(jc.is_failed);
            assertTrue(jc.is_running);
            assertTrue(jc.reports_progress);
            
            % Check never fails on waiting as waiting time is 0
            ok = mpi.check_message(3,'running');
            assertFalse(ok);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,'running');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,0);
            assertFalse(jc.is_failed);
            assertTrue(jc.is_running);
            assertTrue(jc.reports_progress);
            
            % never fails on time-out as waiting time is 0
            [jc,is_running] = jc.check_and_set_job_state(mpi,'');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,0);
            assertFalse(jc.is_failed);
            assertTrue(jc.is_running);
            assertTrue(jc.reports_progress);
            
            % send message with timing and fail on time-out
            mess = LogMessage(1,10,0.01,'bla bla bla');
            ok = mpi.send_message(3,mess);
            assertTrue(ok);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,'running');
            assertTrue(is_running);
            assertEqual(jc.waiting_count,0);
            assertFalse(jc.is_failed);
            assertTrue(jc.is_running);
            assertTrue(jc.reports_progress);
            
            pause(0.2);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,'');
            assertFalse(is_running);
            assertEqual(jc.waiting_count,0);
            assertTrue(jc.is_failed);
            assertFalse(jc.is_running);
            assertTrue(jc.reports_progress);
            
            % recover on getting completed message
            mess = aMessage('completed');
            mess.payload = 'dummy job output';
            ok = mpi.send_message(3,mess);
            assertTrue(ok);
            
            [jc,is_running] = jc.check_and_set_job_state(mpi,'completed');
            assertFalse(is_running);
            assertEqual(jc.waiting_count,0);
            assertFalse(jc.is_failed);
            assertFalse(jc.is_running);
            assertTrue(jc.is_finished);
            assertTrue(jc.reports_progress);
            assertEqual(jc.outputs,'dummy job output');
            
            ok = mpi.check_message(3,'completed');
            assertFalse(ok);
            
            % fail will even kill completed, though it should not ever
            % happen, though output still exist
            ok = mpi.send_message(3,'failed');
            assertTrue(ok);
            [jc,is_running] = jc.check_and_set_job_state(mpi,'failed');
            assertFalse(is_running);
            assertTrue(jc.is_failed);
            assertTrue(isempty(jc.fail_reason));
            assertEqual(jc.outputs,'dummy job output');
        end
        
        function test_log(this)
            jc = jobController(2);
            log = jc.get_job_info();
            assertEqual(log,'JobN:02| starting |')
        end
        
    end
end
