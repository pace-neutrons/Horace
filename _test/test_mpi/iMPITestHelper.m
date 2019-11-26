classdef iMPITestHelper<iMessagesFramework
    % helper class to test iMessagesFramework methods,
    % defining empty abstract methods.
    methods
        function obj=iMPITestHelper(varargin)
            obj= obj@iMessagesFramework(varargin{:});
        end
        % Abstract interface
        function obj = init_framework(obj,framework_info)
            
        end        
        function cs  = build_control(obj,task_id,varargin)
        end
        %------------------------------------------------------------------
        function fn = mess_name(obj,task_id,mess_name)
        end
        
        function [ok,err_mess] = send_message(obj,task_id,message)
        end                
        function [is_ok,err_mess,message] = receive_message(obj,task_id,mess_name)
        end
                
        function all_messages_names = probe_all(obj,task_ids)
        end
        
        function [all_messages,task_ids] = receive_all(obj,task_ids)
        end
        function ok = labBarrier(obj)
        end
        function clear_messages(obj)
        end        
        %------------------------------------------------------------------
        % delete all messages belonging to this instance of messages
        % framework and shut the framework down.
        function finalize_all(obj)
            rmdir(obj.mess_exchange_folder,'s');
        end
        
        % method verifies if job has been canceled
        function is = is_job_canceled(obj)
        end
    end
    methods(Access=protected)
        % return the labindex
        function ind = get_lab_index_(obj)
            ind = 0;
        end
        function nl = get_num_labs_(obj)
            nl = 0;
        end
        
    end
        

end
