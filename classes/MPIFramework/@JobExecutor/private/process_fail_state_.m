function [ok,err_mess] = process_fail_state_(obj,ME,is_tested)

if strcmpi(ME.identifier,'JOB_EXECUTOR:cancelled') || strcmpi(ME.identifier,'MESSAGE_FRAMEWORK:cancelled')
    is_cancelled = true;
    err_text = sprintf('Task N%d cancelled',...
        obj.labIndex);
else
    is_cancelled = false;
    err_text = sprintf('Task N%d failed at jobExecutor: %s. Reason: %s',...
        obj.labIndex,class(obj),ME.message);
end
mess = FailMessage(err_text,ME);
% send cancelled message to all other workers to finish their
% current job at log point.
if ~is_cancelled
    mf = obj.mess_framework;
    n_labs = mf.numLabs;
    this_lid = obj.labIndex;
    for lid=1:n_labs
        if lid ~=this_lid
            obj.mess_framework.send_message(lid,'cancelled');
        end
    end
end

if is_tested
    [ok,err_mess]=obj.finish_task(mess,'-asynchroneous');
else
    [ok,err_mess]=obj.finish_task(mess);
end

