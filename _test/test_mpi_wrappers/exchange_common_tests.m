classdef exchange_common_tests < MPI_Test_Common
    % Class to test common interface for all MPI frameworks used by Herbert
    %
    
    properties
        % the name of the class, responsible for sending in test mode
        sender_name
        % the name of the class, responsible for receivinv in test mode
        receiver_name
        % true if sender and receiver in test mode are the same classes
        sedner_eq_receiver = false;
    end
    
    methods
        function obj = exchange_common_tests(test_name,sender,receiver)
            obj = obj@MPI_Test_Common(test_name);
            obj.sender_name   = sender;
            obj.receiver_name = receiver;
            obj.sedner_eq_receiver = strcmp(sender,receiver);
        end
        function test_SendReceive(obj)
            % Test communications in test mode
            if obj.ignore_test
                return
            end
            m_send = feval(obj.sender_name);
            clob_s = onCleanup(@()(finalize_all(m_send )));
            if obj.sedner_eq_receiver
                m_receiv = m_send;
                clob_r = [];
            else
                m_receiv = feval(obj.receiver_name);
                clob_r = onCleanup(@()(finalize_all(m_receiv )));
            end
            
            
            assertEqual(double(m_send.labIndex), 1);
            assertEqual(double(m_send.numLabs), 10);
            
            mess = LogMessage(1, 10, 1, []);
            [ok, err_mess] = m_send.send_message(5, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok, err_mess, messR] = m_receiv.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);
            %-----------------------------------------------------------
            [ok, err_mess, messR] = m_receiv.receive_message(5, mess.mess_name);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));
            %--------------------------------------------------------------
            %
            % blocking receive in test mode is not alowed
            [ok, err_mess, messR] = m_receiv.receive_message(5, 'init');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            
            [ok, err_mess] = m_send.send_message(4, mess);
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            
            [ok, err_mess, messR] = m_receiv.receive_message(5, 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertTrue(isempty(messR));
            
            [ok, err_mess, messR] = m_receiv.receive_message(4, 'any');
            assertEqual(ok, MESS_CODES.ok);
            assertTrue(isempty(err_mess));
            assertEqual(mess, messR);
            
            
            [ok, err_mess] = m_send.send_message(11, mess); % out-of range
            assertEqual(ok, MESS_CODES.a_send_error);
            assertTrue(isa(err_mess,'MException'));
            
            clear m_send;
            clear m_receiv;
        end
        %
        function test_Receive_fromAny_is_error(obj)
            m_receiv = feval(obj.receiver_name);
            clob_r = onCleanup(@()(finalize_all(m_receiv )));
            
            
            [ok, err_mess, messR] = m_receiv.receive_message('any', 'any');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message(-1, 'any');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message([], 'any');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            
            [ok, err_mess, messR] = m_receiv.receive_message('any', 'data');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message(-1, 'data');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message([], 'data');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message('any', 'log');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message(-1, 'log');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            [ok, err_mess, messR] = m_receiv.receive_message([], 'log');
            assertEqual(ok, MESS_CODES.a_recieve_error);
            assertTrue(isempty(messR));
            assertTrue(isa(err_mess,'MException'));
            
            clear m_receiv;
        end
    end
end

