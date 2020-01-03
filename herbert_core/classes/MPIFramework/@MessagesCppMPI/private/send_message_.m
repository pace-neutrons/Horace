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

task_id = uint32(task_id);
tag =int32(mess.tag);
%
try
    if is_blocking
        error('MESSAGES_CPP_MPI:not_implemented',...
            'blocking comminications are not yet implemented')
    else
        contents = hlp_serialize(mess);
        
        obj.mpi_framework_holder_ = cpp_communicator('labSend',...
            obj.mpi_framework_holder_,...
            task_id,tag,uint8(is_blocking),contents);
    end
catch ME
    if strncmpi(ME.identifier,'MPI_MEX_COMMUNICATOR:',numel('MPI_MEX_COMMUNICATOR:'))
        ok = MESS_CODES.a_send_error;
        err_mess = ME.message;
    else
        rethrow(ME);
    end
end
