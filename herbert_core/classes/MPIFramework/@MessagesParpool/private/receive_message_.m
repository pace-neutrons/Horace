function [err_code,err_mess,message] = receive_message_(obj,varargin)
% receive specific MPI message


[id,tag] = get_mess_id_(varargin{:});
%
message = obj.get_interrupt(id);
if ~isempty(message)
    err_code = MESS_CODES.ok;
    err_mess = [];    
    return;
end

[message,tag,source,err_code,err_mess] = attempt_to_receive(obj,id,tag);
obj.set_interrupt(message,source);

if ~isempty(message) && (~(message.is_blocking || message.is_persistent))
    % collapse similar status messages
    while obj.MPI_.mlabProbe(source,tag)
        [message,tag,source,err_code,err_mess] = attempt_to_receive(obj,source,tag);
    end
end

function [message,tag,source,err_code,err_mess] = attempt_to_receive(obj,id,tag)

err_code = MESS_CODES.ok;
err_mess = [];
try
    [message,tag,source] = obj.MPI_.mlabReceive(id,tag);
catch Err
    err_code = MESS_CODES.a_recieve_error;
    err_mess = Err;
    
    message = [];
    tag = [];
    source  = [];
    return
end


