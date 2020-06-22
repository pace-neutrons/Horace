function [err_code,err_mess,message] = receive_message_(obj,from_task_id,varargin)
% receive specific MPI message from the task_id provided as input



err_code = MESS_CODES.ok;
err_mess = [];

% call parent function to check and validate inputs
[from_task_id,mess_name,synchroneous]=obj.check_receive_inputs(from_task_id,varargin{:});

tag = MESS_NAMES.mess_id(mess_name);

%
message = obj.get_interrupt(from_task_id);
if ~isempty(message)
    return;
end
% if fresh interrupt in the system, receive it
ir_tags = MESS_NAMES.instance().interrupt_tags;
for i=1:numel(ir_tags) 
    [ir_names,ir_from]  = obj.MPI_.mlabProbe(from_task_id,ir_tags(i));
    if ~isempty(ir_names)
        tag = ir_tags(i);
        synchroneous = false;
        break
    end
end

message = obj.MPI_.mlabReceive(from_task_id,tag,synchroneous);
obj.set_interrupt(message,from_task_id);



