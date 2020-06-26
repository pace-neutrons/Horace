classdef MFTester<MessagesFilebased
    methods
        function obj=MFTester(varargin)
            obj= obj@MessagesFilebased(varargin{:});
            obj.time_to_fail = 2;
        end
        function mess_fname = job_stat_fname(obj,job_id,mess_name)
            mess_fname  = obj.job_stat_fname_(job_id,mess_name);
        end
        %
%         function [start_queue_num,free_queue_num]=list_queue_messages_pub(obj,...
%                 mess_name,send_from,sent_to,varargin)
%             % public tester method for protected list_queue_messages method.
%             [start_queue_num,free_queue_num]=obj.list_queue_messages(...
%                 mess_name,send_from,sent_to,varargin{:});
%         end
        
    end
end
