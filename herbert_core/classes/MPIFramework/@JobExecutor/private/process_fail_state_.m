function mess = process_fail_state_(obj,ME,log_file_h)

DO_LOGGING = exist('log_file_h', 'var');
if ~DO_LOGGING; log_file_h = []; end

switch ME.identifier
  case {'JOB_EXECUTOR:cancelled', 'MESSAGE_FRAMEWORK:cancelled'}
    is_cancelled = true;
    err_text = sprintf('Task N%d cancelled',...
        obj.labIndex);

  otherwise
    is_cancelled = false;
    err_text = sprintf('Task N%d failed at jobExecutor: %s. Reason: %s',...
        obj.labIndex,class(obj),ME.message);
end

mess = FailedMessage(err_text,ME);

% send cancelled message to all other workers to finish their
% current job at log point.
if is_cancelled
    log_disp_message(log_file_h,'---> Job received "cancelled" message\n');
else
    log_disp_message(log_file_h,'---> Sending "cancelled" message to neighbours\n');

    mf = obj.mess_framework;
    n_labs = mf.numLabs;
    this_lid = mf.labIndex;

    % provide 'cancelled' message with the information about the failure to
    % ensure that if host completed its job and is reducing message,
    % correct cancelled information will be processed.
    cm = CancelledMessage();
    cm.payload = ME;

    for lid=1:n_labs
        if lid ~=this_lid
            [ok,err]=mf.send_message(lid,cm);
            if ok ~=MESS_CODES.ok
                error('JOB_EXECUTOR:runtime_error',...
                    ' Error %s sending "cancelled" message to neighouring node %d',...
                    err,lid);
            end
        end
    end
end

% finish task, in particular, removes all messages, directed to this
% lab

% stop until other nodes fail due to cancellation and come
% here
% job has been interrupted before the barrier in the job
% loop has been reached, so wait here for completed jobs to finish
if obj.do_job_completed
    log_disp_message(log_file_h,'--->Failing job not waiting for others\n');
else
    log_disp_message(log_file_h,'--->Arriving at Incompleted job barrier\n');
    obj.labBarrier(true);
end

end

function log_disp_message(fh,mess)
    if DO_LOGGING
        fprintf('**PROCESS_FAIL_STATE: %s ****************************\n',mess);
        fprintf(fh,'**PROCESS_FAIL_STATE: %s ****************************\n',mess);
    end
end

end
