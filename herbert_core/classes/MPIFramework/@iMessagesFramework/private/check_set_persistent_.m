function check_set_persistent_(obj,mess,source_address)
% check if the input message is a persistent message (the message
% describing a state of the source which persists until the
% current job is completed or aborted) and if the message is
% present store it in framework until the task is completed
% or aborted

if isempty(mess)
    return;
end
if MESS_NAMES.is_persistent(mess)
    if isempty(obj.persistent_fail_message_)
        obj.persistent_fail_message_ =  containers.Map('KeyType','int32','ValueType','any');
    end
    obj.persistent_fail_message_(int32(source_address)) = mess;
end
