classdef exchange_common_tests < MPI_Test_Common
    % Class to test common interface for all MPI frameworks used by Herbert
    %
    
    properties
        % the name of the class, responsible for sending/receiving framework
        % messages in test mode
        comm_name
        
    end
    
    methods
        function obj = exchange_common_tests(test_name,comm_name)
            obj = obj@MPI_Test_Common(test_name);
            obj.comm_name   = comm_name;
        end
        function test_SendProbe(obj)
            % Test communications in test mode
            if obj.ignore_test
                return
            end
            m_comm = feval(obj.comm_name);
            clob_s = onCleanup(@()(finalize_all(m_comm )));
            
            assertEqual(double(m_comm.labIndex), 1);
            assertEqual(double(m_comm.numLabs), 10);
            
            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = m_comm.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [mess_names, source_id_s] = m_comm.probe_all('any', 'any');
            assertEqual(numel(mess_names), 1);
            assertEqual(numel(source_id_s), 1);
            assertEqual(double(source_id_s(1)), (5));
            assertEqual(mess_names{1}, mess.mess_name);
            
            [ok, err_mess] = m_comm.send_message(7, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [mess_names, source_id_s] = m_comm.probe_all('any', 'any');
            assertEqual(numel(mess_names), 2);
            assertEqual(numel(source_id_s), 2);
            assertEqual(double(source_id_s(1)), (5));
            assertEqual(double(source_id_s(2)), (7));
            assertEqual(mess_names{1}, mess.mess_name);
            
        end
        
        function test_Send3Receive1Asynch(obj)
            % Test communications in test mode
            if obj.ignore_test
                return
            end
            m_comm = feval(obj.comm_name);
            clob_s = onCleanup(@()(finalize_all(m_comm )));
            
            
            assertEqual(double(m_comm.labIndex), 1);
            assertEqual(double(m_comm.numLabs), 10);
            
            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = m_comm.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            mess = LogMessage(2, 10, 3, []);
            [ok, err_mess] = m_comm.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            mess = LogMessage(3, 10, 5, []);
            [ok, err_mess] = m_comm.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok, err_mess, messR] = m_comm.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            assertEqual(mess, messR);
            
            [mess_names, source_id_s] = m_comm.probe_all(5, 'any');
            assertTrue(isempty(mess_names));
            assertTrue(isempty(source_id_s));
            
        end
        
        function test_SendReceive(obj)
            % Test communications in test mode
            if obj.ignore_test
                return
            end
            m_comm = feval(obj.comm_name);
            clob_s = onCleanup(@()(finalize_all(m_comm )));
            
            
            assertEqual(double(m_comm.labIndex), 1);
            assertEqual(double(m_comm.numLabs), 10);
            
            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = m_comm.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok, err_mess, messR] = m_comm.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);
            %-----------------------------------------------------------
            [ok, err_mess, messR] = m_comm.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));
            %--------------------------------------------------------------
            %
            % blocking receive in test mode is not alowed
            f = @()receive_message(m_comm,5, 'init');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:runtime_error')
            
            
            [ok, err_mess] = m_comm.send_message(4, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok, err_mess, messR] = m_comm.receive_message(5, 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));
            
            [ok, err_mess, messR] = m_comm.receive_message(4, 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);
            
            
            % out-of range
            f = @()send_message(m_comm, 11, mess);
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument',...
                'Should throw invalid argument on out-of range message but got something else')
            
            clear clob_r;
        end
        %
        function test_Receive_fromAny_is_error(obj)
            m_comm = feval(obj.comm_name);
            clob_r = onCleanup(@()(finalize_all(m_comm )));
            
            f = @()receive_message(m_comm,'any', 'any');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()receive_message(m_comm,-1, 'any');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()receive_message(m_comm,[], 'any');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            
            f = @()receive_message(m_comm,'any', 'data');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            
            f = @()receive_message(m_comm,-1, 'data');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            
            f = @()receive_message(m_comm,[], 'data');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()receive_message(m_comm,'any', 'log');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            
            f = @()receive_message(m_comm,-1, 'log');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            f = @()receive_message(m_comm,[], 'log');
            assertExceptionThrown(f, 'MESSAGES_FRAMEWORK:invalid_argument')
            
            clear clob_r;
        end
    end
end

