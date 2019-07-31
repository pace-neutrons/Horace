function [err_code,err_mess,message] = receive_message_(obj,varargin)
% receive specific MPI message

% [is,err_code,err_mess] = check_job_cancelled(obj);
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

try
    if isempty(id)
        message = labReceive();
    elseif isempty(tag)
        message = labReceive(id);
    else % nargin == 3 or more
        message = labReceive(id,tag);
    end
catch Err
    err_code = MESS_CODES.a_recieve_error;
    err_mess = Err;
    message = [];
end

% function [is,err_code,err_mess]=check_job_cancelled(obj)
% err_code = MESS_CODES.ok;
% err_mess = [];
% is = false;
% t_cancel = MESS_NAMES.mess_id('cancelled');
% isDataAvail = labProbe('any',t_cancel );
% if isDataAvail
%     is = true;
%     err_code = MESS_CODES.job_cancelled;
%     err_mess = MException('MESSAGE_FRAMEWORK:cancelled',...
%         sprintf('Job with ID: %s has been cancelled. Cancel message received',obj.job_id));
% end
