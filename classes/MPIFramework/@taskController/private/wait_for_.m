function fail = wait_for_(obj,mpi,mess_name)
%
wait_count = 0;
messages_names = mpi.probe_all(obj.task_id);
while ~ismember(mess_name,messages_names) && (wait_count  <= obj.fail_limit_)
    pause(1)
    messages_names = mpi.probe_all(obj.task_id);
    wait_count   = wait_count+1;
end
if wait_count  > obj.fail_limit_
    fail = true;
else
    fail = false;
end

