function [err_code,err_mess,message] = receive_message_(obj,varargin)
% receive specific MPI message

err_code = MESS_CODES.ok;
err_mess = [];


[id,tag,synchroneous] = get_mess_id_(obj,varargin{:});
%
message = obj.get_interrupt(id);
if ~isempty(message)
    err_code = MESS_CODES.ok;
    err_mess = [];
    return;
end

[message,tag,source] = obj.MPI_.mlabReceive(id,tag,synchroneous);
obj.set_interrupt(message,source);

if ~isempty(message) && (~(message.is_blocking || message.is_persistent))
    % collapse similar status messages
    while obj.MPI_.mlabProbe(source,tag)
        [message,tag,source] = obj.MPI_.mlabReceive(id,tag);
    end
end

