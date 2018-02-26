function fail = wait_for_(obj,mpi,mess_name)
%
wait_count = 0;
messages_names = mpi.probe_all(obj.task_id);
while no_message(messages_names,mess_name) && (wait_count  <= obj.fail_limit_)
    pause(0.2)
    messages_names = mpi.probe_all(obj.task_id);
    wait_count   = wait_count+1;
end
if wait_count  > obj.fail_limit_
    fail = true;
else
    fail = false;
end


function no =no_message(messages_names,mess_name)
no = true;
if ~isempty(messages_names{1})
    if ismember(mess_name,messages_names)
        no = false;
    end
end