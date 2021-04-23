classdef MessagesFileBasedMPI_mirror_tester < MFTester
    % The class, which mimicks the file-based messages mirroring
    %
    % i.e.
    % when one sends a message to a particular worker, the class reflects it
    % and provides the sent message as available from the worker to which
    % the initial message has been sent
    properties(Access=protected)
        mess_name_fun_
    end
    properties
        inverse_fname_f
    end
    
    
    methods
        function obj = MessagesFileBasedMPI_mirror_tester(varargin)
            % create intialization structure, which would represent 10
            % workers, communicating over file-based MPI messages
            if nargin == 0
                init_struct = iMessagesFramework.build_worker_init(tmp_dir, ...
                    'test_FB_message', 'MessagesFilebased', 1, 10,'test_mode');
            else
                init_struct = varargin{1};
            end
            obj=obj@MFTester(init_struct);
            obj.mess_name_fun_  = @(name,lab_to,lab_from,is_sender)....
                MessagesFilebased.mess_fname_(obj,lab_to,name,lab_from,is_sender);
        end
        function [ok,err_mess,message] = send_message(obj,targ,varargin)
            obj.mess_name_fun_ = @(name,lab_to,lab_from,is_sender) ...
                MessagesFileBasedMPI_mirror_tester.mess_fname_rev(obj,lab_from,name,lab_to,true);
            
            obj.inverse_fname_f = obj.mess_name_fun_;
            
            [ok,err_mess,message] = send_message@MessagesFilebased(obj,targ,varargin{:});
            obj.mess_name_fun_  = @(name,lab_to,lab_from,is_sender)....
                MessagesFilebased.mess_fname_(obj,lab_to,name,lab_from,is_sender);
            
            
        end
        function [receive_now,mess_names,n_steps] = check_whats_coming_tester(obj,task_ids,mess_name,mess_array,n_steps)
            [receive_now,mess_names,n_steps] = obj.check_whats_coming(task_ids,mess_name,mess_array,n_steps);
        end
        
    end
    %
    methods (Access=protected)
        function mess_fname = job_stat_fname_(obj,lab_to,mess_name,lab_from,varargin)
            %build filename for a specific message
            if ~exist('lab_from', 'var')
                lab_from = obj.labIndex;
            end
            mess_fname= obj.mess_name_fun_(mess_name,lab_to,lab_from,varargin{:});
            
        end

    end
    methods(Static,Access=protected)
        function mess_fname = mess_fname_rev(obj,lab_to,mess_name,lab_from,is_sender)
            % Build filename for a specific message, reflected from the target node.
            % Inputs:
            % lab_to    -- the address of the lab to send message to.
            % mess_name -- the name of the message to send
            % lab_from  -- if present, the number of the lab to send
            %              message from, if not there, from this lab
            %              assumed
            % is_sender     -- make sense for data messages only (blocking messages)
            %               , as they  have to be numbered, and each send
            %               must meet its receiver without overtaking.
            %
            %               if true, defines data message name for sender.
            %               false - for received.
            % Returns
            if strcmp(mess_name,obj.interrupt_chan_name_)
                is_blocking = false;
            else
                is_blocking = MESS_NAMES.is_blocking(mess_name);
            end
            
            if is_blocking
                if is_sender
                    mess_num = obj.send_data_messages_count_(lab_from+1);
                else %receiving
                    mess_num = obj.receive_data_messages_count_(lab_from+1);
                end
                mess_fname = fullfile(obj.mess_exchange_folder,...
                    sprintf('mess_%s_FromN%d_ToN%d_MN%d.mat',...
                    mess_name,lab_from,lab_to,mess_num));
            else
                mess_fname= fullfile(obj.mess_exchange_folder,...
                    sprintf('mess_%s_FromN%d_ToN%d.mat',...
                    mess_name,lab_from,lab_to));
            end
        end
    end
    
    
end

