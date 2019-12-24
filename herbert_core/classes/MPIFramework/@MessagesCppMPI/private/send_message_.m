function [ok,err_mess] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%

ok = MESS_CODES.ok;
err_mess = [];
if ischar(message)
    mess = aMessage(message);
elseif isa(message,'aMessage')
    mess = message;
end
% convert types into defined types to transfer to cpp_communicator
is_blocking = logical(mess.is_blocking);
tag =uint32(mess.tag);
task_id = uint32(task_id);
%
if is_blocking
    contents = hlp_serialize(mess);
    try
        obj.mpi_framework_holder_ = cpp_communicator('send',...
            obj.mpi_framework_holder_,task_id,tag,is_blocking,contents);
    catch ME
        if strcmpi(ME.identifier,'')
            ok = MESS_CODES.a_send_error;
            err_mess = ME.message;
        else
            rethrow(ME);
        end
    end
else
end
