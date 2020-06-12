function set_interrupt_(obj,mess,source_address)
% check if a message is an interrupt message  (the message
% describing a state of the source which persists until the
% current job is completed or aborted) and if the message is
% present store it in framework until the task is completed
% or aborted.
if isempty(mess)
    return;
end
if mess.is_persistent
    if isempty(obj.persistent_fail_message_)
        obj.persistent_fail_message_ =  containers.Map('KeyType','int32','ValueType','any');
    end
    obj.persistent_fail_message_(int32(source_address)) = mess;
end
