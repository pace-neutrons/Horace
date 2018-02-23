function     [obj,not_exist] = get_output_(obj,mpi)
% Retrieve job outputs and attach it to the taksController

% get job output
not_exist = false;
[ok,err,mess] = mpi.receive_message(obj.task_id,'completed');
if ok == MES_CODES.ok
    obj.outputs = mess.payload;
elseif ok == MES_CODES.not_exist
    not_exist  = true;
else
    obj = obj.set_failed(...
        spfintf('Task %d Not able to receive "job_completed" message. Err: ',...
        obj.task_id,err));
end
