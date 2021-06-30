classdef test_Cluster_check_progress< TestCase
    %
    %
    properties
        cluster_tester
    end
    methods
        %
        function obj=test_Cluster_check_progress(name)
            if ~exist('name', 'var')
                name = 'test_Cluster_check_progress';
            end
            obj = obj@TestCase(name);
            obj.cluster_tester = ClusterParpoolStateTester();
        end
        %
        function test_completed_mess_received_after_job_completeon(obj)
            % finish job on receiving "completed" message
            ct = obj.cluster_tester;
            
            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
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
            
            
            % finish job on receiving 'completed' message
            ct.init_state = 'finished';
            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'completed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'completed'))
            
            fin_mess = CompletedMessage('good completeon');
            [ok,mess]= comm.send_message(1,fin_mess);
            assertTrue(isempty(mess));
            assertEqual(ok,MESS_CODES.ok);

            [completed,ct] = ct.check_progress();
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'completed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'completed'))
            
            %
        end
        
        %
        function test_completed_mess_received(obj)
            % finish job on receiving "completed" message
            ct = obj.cluster_tester;
            
            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
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
            ct = obj.cluster_tester;
            
            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
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
        
        function test_running_no_progress_messages(obj)
            ct = obj.cluster_tester;
            
            % init cluster with 3 workers
            ct.init_state = 'running';
            ct = ct.init(3);
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
            [completed,ct] = ct.check_progress();
            assertFalse(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'completed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'completed'))
            %
            [completed,ct] = ct.check_progress();
            assertTrue(completed);
            assertTrue(ct.status_changed);
            assertEqual(ct.status_name,'failed');
            ct = ct.display_progress();
            log = ct.log_value;
            assertTrue(contains(log,'failed'))
        end
        
        
        function test_init_cluster_fails_control_fail_message(obj)
            ct = obj.cluster_tester;
            
            % init cluster with 3 workers
            ct.init_state = 'failed';
            ct = ct.init(3);
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
            % message ignored as this framework reported failure from
            % beginning
            assertFalse(contains(log,'Simulated failure reported'))
        end
        %
        function test_init_cluster_fails_control_no_messages(obj)
            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct.init_state = 'failed';
            ct = ct.init(3);
            %
            % ensure wait receives
            [ct,ok]=ct.wait_started_and_report(0.001);
            assertFalse(ok);
            log = ct.log_value;
            assertTrue(contains(log,'failed'))
        end
        %
        function test_init_cluster_fails_timeout(obj)
            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct = ct.init(3);
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
            ct = obj.cluster_tester;
            % init cluster with 3 workers
            ct = ct.init(3);
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
    end
end


