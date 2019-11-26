function [ok,err_mess] = process_fail_state_(obj,ME,is_tested)

if strcmpi(ME.identifier,'JOB_EXECUTOR:canceled') || strcmpi(ME.identifier,'MESSAGE_FRAMEWORK:canceled')
    is_canceled = true;
    err_text = sprintf('Task N%d canceled',...
        obj.labIndex);
else
    is_canceled = false;
    err_text = sprintf('Task N%d failed at jobExecutor: %s. Reason: %s',...
        obj.labIndex,class(obj),ME.message);
end
%disp(['processing fail state, forming message: ',ME.identifier]);
mess = FailMessage(err_text,ME);
% send canceled message to all other workers to finish their
% current job at log point.
if ~is_canceled
    mf = obj.mess_framework;
    n_labs = mf.numLabs;
    this_lid = obj.labIndex;
    for lid=1:n_labs
        if lid ~=this_lid
            obj.mess_framework.send_message(lid,'canceled');
        end
    end
end
disp(['processing fail state: finish task is tested: ',num2str(is_tested)]);
if is_tested
    [ok,err_mess]=obj.finish_task(mess,'-asynchronous');
else
    [ok,err_mess]=obj.finish_task(mess);
end

