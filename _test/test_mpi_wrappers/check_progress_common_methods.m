classdef check_progress_common_methods< TestCase
    %
    %
    properties
        cluster_tester
        test_disabled
    end
    methods
        %
        function obj=check_progress_common_methods(class_instance,name)
            if ~exist('name', 'var')
                name = ['test_progress_',class(class_instance)];
            end
            obj = obj@TestCase(name);
            obj.cluster_tester = class_instance;
        end
        %
        function test_completed_mess_not_received_and_job_completion_fails(obj)
            if obj.test_disabled
                skipTest(sprintf('test_completed_mess_not_received_and_job_completion_fails for class %s is disabled',class(obj)))
                return
            end
            % finish job on receiving "completed" message
            ct = obj.cluster_tester;

            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            % use reflective exchange framework to receive ready message
            comm = ct.get_exchange_framework();
            [ok,mess]= comm.send_message(1,'ready');
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0);
            assertTrue(ok);
            log = ct.log_value;
            assertTrue(contains(log,'ready'))
            assertEqual(ct.status_name,'ready');


            % finish job on receiving getting into "completed" state
            ct.init_state = 'finished';
            [completed,ct] = ct.check_progress();
            % fails as normal completion needs "completed" messages
            % to be send and received after the parallel job ceases to run
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'failed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'failed'))

            %
        end

        %
        function test_completed_mess_received(obj)
            if obj.test_disabled
                skipTest(sprintf('test_completed_mess_received for class %s is disabled',class(obj)))
                return
            end

            % finish job on receiving "completed" message
            ct = obj.cluster_tester;

            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            % use reflective exchange framework to receive ready message
            comm = ct.get_exchange_framework();
            [ok,mess]= comm.send_message(1,'ready');
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0);
            assertTrue(ok);
            log = ct.log_value;
            assertTrue(contains(log,'ready'))
            assertEqual(ct.status_name,'ready');

            % Different frameworks receive log vs completed message in
            % different order
            %[ok,mess]= comm.send_message(1,LogMessage(0,10,0.5));
            %assertTrue(isempty(mess));
            %assertEqual(ok,MESS_CODES.ok);

            % finish job on receiving 'completed' message
            [ok,mess]= comm.send_message(1,CompletedMessage());
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);
            %ct.init_state = 'finished';
            [completed,ct] = ct.check_progress();
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'completed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'completed'))
            %
        end


        function test_running_progress_messages_delivered(obj)
            if obj.test_disabled
                skipTest(sprintf('test_running_progress_messages_delivered for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;

            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            % use reflective exchange framework to receive ready message
            comm = ct.get_exchange_framework();
            [ok,mess]= comm.send_message(1,'ready');
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0);
            assertTrue(ok);
            log = ct.log_value;
            assertTrue(contains(log,'ready'))
            assertEqual(ct.status_name,'ready');

            [ok,mess]= comm.send_message(1,LogMessage(0,10,0.5));
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'log');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'running'))
            % next request -- nothing changed
            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertFalse(ct.status_changed);
            assertEqual(ct.status_name,'log');
            ct = ct.display_progress();
            log = ct.log_value;
            assertEqual(log,'.')

            [ok,mess]= comm.send_message(1,LogMessage(5,10,0.5));
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);
            % next request -- progress received
            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'log');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'#5'))


            [ok,mess]= comm.send_message(1,CompletedMessage());
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);
            ct.init_state = 'finished';
            [completed,ct] = ct.check_progress();
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'completed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'completed'))
            %
        end

        function test_running_no_progress_messages_fails_at_the_end(obj)
            if obj.test_disabled
                skipTest(sprintf('test_running_no_progress_messages_fails_at_the_end for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;

            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            % use reflective exchange framework to receive ready message
            comm = ct.get_exchange_framework();
            [ok,mess]= comm.send_message(1,'ready');
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0.);
            assertTrue(ok);
            log = ct.log_value;
            assertTrue(contains(log,'ready'))
            assertEqual(ct.status_name,'ready');

            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'log');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'running'))
            % next request -- nothing changed
            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertFalse(ct.status_changed);
            assertEqual(ct.status_name,'log');
            ct = ct.display_progress();
            log = ct.log_value;
            assertEqual(log,'.')


            ct.init_state = 'finished';
            % fails as normal completion needs "completed" messages
            % to be send and received after the parallel job ceases to run
            [completed,ct] = ct.check_progress();
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'failed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'failed'))
        end


        function test_init_cluster_fails_receiving_fail_message(obj)
            if obj.test_disabled
                skipTest(sprintf('test_init_cluster_fails_receiving_fail_message for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;

            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));

            % use reflective exchange framework to receive ready message
            % from node 1
            comm = ct.get_exchange_framework();
            [ok,mess]= comm.send_message(1,FailedMessage('Simulated failure reported'));
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            %
            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0.001);
            assertFalse(ok);
            log = ct.log_value;
            assertTrue(contains(log,'failed'))
            assertTrue(contains(log,'Simulated failure reported'))
        end
        %
        function test_init_cluster_fails_control_no_messages(obj)
            if obj.test_disabled
                skipTest(sprintf('test_init_cluster_fails_control_no_messages for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct.init_state = 'failed';
            try
                ct = ct.init(3);
                ct.finalize_all();
                assertTrue(false,'init method should throw if job controls reports initialization fails')
            catch ME
                assertEqual(ME.identifier,'HERBERT:ClusterWrapper:runtime_error')
                assertTrue(contains(ME.message,'failed'))
            end

        end
        %
        function test_init_cluster_fails_timeout(obj)
            if obj.test_disabled
                skipTest(sprintf('test test_init_cluster_fails_timeout for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            ct.cluster_startup_time = 0.01;
            % use reflective exchange framework to receive ready message
            % from node 1
            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0.001);
            assertFalse(ok);
            log = ct.log_value;
            assertTrue(contains(log,'failed'))
        end
        %
        function test_init_cluster_reported_ready(obj)
            if obj.test_disabled
                skipTest(sprintf('test_init_cluster_reported_ready for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct = ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            % use reflective exchange framework to receive ready message
            % from node 1
            comm = ct.get_exchange_framework();
            [ok,mess]= comm.send_message(1,'ready');
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);
            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0);
            assertTrue(ok);
            log = ct.log_value;
            assertTrue(contains(log,'ready'))
        end
        function test_init_failed_fails(obj)
            if obj.test_disabled
                skipTest(sprintf('test_init_failed_fails for class %s is disabled',class(obj)))
                return
            end

            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct=ct.init(3);
            clOb = onCleanup(@()finalize_all(ct));
            ct.init_state = 'init_failed';
            %
            [completed,ct] = ct.check_progress();
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'failed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'failed'))
            assertTrue(contains(log,'has not been started'))
        end

    end
end
