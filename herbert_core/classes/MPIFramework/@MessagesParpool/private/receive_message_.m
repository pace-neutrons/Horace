function [err_code,err_mess,message] = receive_message_(obj,varargin)
% receive specific MPI message

err_code = MESS_CODES.ok;
err_mess = [];


[id,tag] = get_mess_id_(varargin{:});
%
message = obj.get_interrupt(id);
if ~isempty(message);   return; end


try
    message = obj.MPI_.labReceive(id,tag);
    obj.set_interrupt(message,id);   
catch Err
    err_code = MESS_CODES.a_recieve_error;
    err_mess = Err;
    message = [];
end


