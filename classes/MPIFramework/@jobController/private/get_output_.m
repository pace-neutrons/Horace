function     obj = get_output_(obj,mpi)
% Retrieve job outputs and attach it to the jobController

% get job output
[ok,err,mess] = mpi.receive_message(obj.job_id,'completed');
if ~ok
    obj = obj.set_failed(['Not able to receive "job_completed" message. Err: ',...
        err]);
else
    obj.outputs = mess.payload;    
end
