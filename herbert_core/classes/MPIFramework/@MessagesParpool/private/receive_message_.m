function [err_code,err_mess,message] = receive_message_(obj,varargin)
% receive specific MPI message

% [is,err_code,err_mess] = check_job_canceled(obj);
% if is  
%     message = [];
%     return;
% end
err_code = MESS_CODES.ok;
err_mess = [];


[id,tag,labReceiveSimulator] = get_mess_id_(varargin{:});
% disabled due to the bug in the parallel parser
% if ~isempty(labReceiveSimulator)
%     labReceive = labReceiveSimulator();
% end
message = obj.check_get_persistent(id);
if ~isempty(message);   return; end


try
    if isempty(id)
        [message,id,tag] = labReceive;
    elseif isempty(tag)
        message = labReceive(id);
    else % nargin == 3 or more
        message = labReceive(id,tag);
    end
    obj.check_set_persistent(message,id);
   
catch Err
    err_code = MESS_CODES.a_recieve_error;
    err_mess = Err;
    message = [];
end

% function [is,err_code,err_mess]=check_job_canceled(obj)
% err_code = MESS_CODES.ok;
% err_mess = [];
% is = false;
% t_cancel = MESS_NAMES.mess_id('canceled');
% isDataAvail = labProbe('any',t_cancel );
% if isDataAvail
%     is = true;
%     err_code = MESS_CODES.job_canceled;
%     err_mess = MException('MESSAGE_FRAMEWORK:canceled',...
%         sprintf('Job with ID: %s has been canceled. Cancel message received',obj.job_id));
% end
