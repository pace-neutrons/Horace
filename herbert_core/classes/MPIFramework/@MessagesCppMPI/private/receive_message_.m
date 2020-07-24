function [err_code,err_mess,mess] = receive_message_(obj,from_task_id,mess_name,is_blocking)
% Receive message from job with the task_id (MPI rank) specified as input
% if mess_name == 'any', receive any tag.
%
err_code = MESS_CODES.ok;
err_mess = [];
message  = [];

if any(from_task_id==0)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'CPP messages framework can not communicate with lab 0')
end

mess = obj.get_interrupt(from_task_id);
if ~isempty(mess)
    err_code  =MESS_CODES.ok;
    err_mess=[];
    return;
end
%
% if fresh interrupt in the system, receive it instead of anything else
ir_tag = obj.interrupt_chan_tag_;
ir_names  = labprobe_all_messages_(obj,from_task_id,ir_tag);
if isempty(ir_names)
    mess_tag = MESS_NAMES.mess_id(mess_name,obj.interrupt_chan_name_);
else
    mess_tag  = ir_tag;
    is_blocking = false;
end

try
    [obj.mpi_framework_holder_,mess_data]=cpp_communicator('labReceive',...
        obj.mpi_framework_holder_,int32(from_task_id),int32(mess_tag),...
        uint8(is_blocking));
catch ERR
    if strcmpi(ERR.identifier,'MPI_MEX_COMMUNICATOR:runtime_error')
        error('MESSAGES_FRAMEWORK:runtime_error',...
            'synchroneous waiting in test mode is not allowed')
    else
        rethrow(ERR);
    end
end
if isempty(mess_data) % no message present at asynchronous receive.
    mess  = [];
else
    mess = hlp_deserialize(mess_data);
end
obj.set_interrupt(mess,from_task_id);
