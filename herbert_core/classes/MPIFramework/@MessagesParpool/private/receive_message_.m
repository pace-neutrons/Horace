function [err_code,err_mess,message] = receive_message_(obj,from_task_id,mess_name,is_blocking)
% receive specific MPI message from the task_id provided as input



err_code = MESS_CODES.ok;
err_mess = [];

%
message = obj.get_interrupt(from_task_id);
if ~isempty(message)
    return;
end
% if fresh interrupt in the system, receive it instead of anything else
ir_tag = obj.interrupt_chan_tag_;
ir_names  = obj.MPI_.mlabProbe(from_task_id,ir_tag);
if isempty(ir_names)
    tag = MESS_NAMES.mess_id(mess_name);
else
    tag = ir_tag;
    is_blocking = false;
end

message = obj.MPI_.mlabReceive(from_task_id,tag,is_blocking);
obj.set_interrupt(message,from_task_id);



