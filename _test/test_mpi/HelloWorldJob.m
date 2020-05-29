classdef HelloWorldJob < JobExecutor

properties (Access = private)
    is_finished_ = false;
end

methods

    function [obj, mess] = init(obj, varargin)
        [obj, mess] = init@JobExecutor(obj, varargin{:});
    end

    function obj = do_job(obj)
        % A job where all non-master nodes send a 'Hello world' message to the
        % the master node. The messages are stored in a cell array and returned
        % to the control process
        try
            obj = obj.do_send_and_receive();
        catch ME
            % Each process writes its error message to a log file
            pid = num2str(feature('getpid'));
            fid = fopen(['err_', pid, '.log'], 'w');
            fwrite(fid, getReport(ME), 'char');
        end
    end

    function obj = do_send_and_receive(obj)
        msg_type = 'started';
        if obj.labIndex ~= 1
            % Any node that's not the master node (node 1) sends message to 1
            msg = [obj.common_data_.base_msg, num2str(obj.labIndex)];
            obj.send_message(msg, msg_type, 1);
        else
            % Say hello from node 1
            msgs = cell(1, obj.mess_framework.numLabs);
            msgs{1} = [obj.common_data_.base_msg, num2str(obj.labIndex)];

            % Node 1 receives messages from other nodes
            for lab_idx = 2:obj.mess_framework.numLabs
                msgs{lab_idx} = obj.receive_message(lab_idx, msg_type);
            end

            % Store the collected messages in the master node's task_output
            obj.task_outputs = msgs;
        end
    end

    function [ok, err_msg] = send_message(obj, msg, msg_type, dest)
        msg_obj = aMessage(msg_type);
        msg_obj.payload = msg;
        [ok, err_msg] = obj.mess_framework.send_message(dest, msg_obj);
    end

    function payload = receive_message(obj, msg_id, name)
        [ok, err_msg, message] = obj.mess_framework.receive_message(msg_id, name);
        if ~ok
            error('HELLOWORLDJOB:receive_message', err_msg);
        end
        payload = message.payload;
    end

    function obj = reduce_data(obj)
        obj.is_finished_ = true;
    end

    function ok = is_completed(obj)
        ok = obj.is_finished_;
    end

end

end
