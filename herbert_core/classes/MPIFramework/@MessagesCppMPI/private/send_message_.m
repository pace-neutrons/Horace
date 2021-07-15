function [ok,err_mess] = send_message_(obj,task_id,message)
% Send message to a job with specified ID
%

ok = MESS_CODES.ok;
err_mess = [];
if ischar(message)
    mess = MESS_NAMES.instance().get_mess_class(message);
elseif isa(message,'aMessage')
    mess = message;
else
    error('MESSAGES_FRAMEWORK:invalid_argument', ...
        'Message must be of type ''char'' or ''aMessage''. Found ''%s''.', ...
        class(message));
end
% convert types into defined types to transfer to cpp_communicator
is_blocking = logical(mess.is_blocking);
if (task_id<1 || task_id > obj.numLabs)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'The message is directed to %d but can be only sent to workers in range [1:%d]',...
        task_id,obj.numLabs);
end

task_id = uint32(task_id);
tag =int32(mess.tag);
%
try
    contents = serialise(mess);
    if mess.is_persistent % use interrupt channel to transfer message
        tag = int32(obj.interrupt_chan_tag_);
    end
    
    obj.mpi_framework_holder_ = cpp_communicator('labSend',...
        obj.mpi_framework_holder_,...
        task_id,tag,uint8(is_blocking),contents);   
catch ME
    if strncmpi(ME.identifier,'MPI_MEX_COMMUNICATOR:',numel('MPI_MEX_COMMUNICATOR:'))
        ok = MESS_CODES.a_send_error;
        err_mess = ME.message;
    else
        rethrow(ME);
    end
end
