function [obj,ok]=wait_started_and_report_(obj,check_time,varargin)
% check for 'ready' message and report cluster ready to user.
% if not ready for some reason, report the failure and
% diagnostics.
%
% Inputs:
% check_time      --  the time interval to wait unit repetative asking
%                     cluster for reply
% Optioal:
% '-force_display' -- if provided, force displaying text log regarless of
%                     the log count
% log_message      -- message, containing the job progress, and to be displayed
%                     by display_progress method
info = [ 'Waiting for parallel cluster: ',obj.starting_cluster_name_,' to start'];
state = StartingMessage();
state.payload = info;

if isa(obj.status,'FailedMessage')
    mess = obj.status;
    pause(check_time);
    obj.status = state;
else
    obj.status = state;
    obj = obj.display_progress(info ,varargin{:});
    [obj,mess]=check_receive(obj);
    started = ~isempty(mess);
    t0 = tic();

    while(~started)
        pause(check_time);
        [~,failed,~,mess]=obj.get_state_from_job_control();

        if failed
            break;
        end

        [obj,mess] =check_receive(obj);
        obj = obj.display_progress();
        started = ~isempty(mess);
        t_pass = toc(t0);

        if t_pass> obj.cluster_startup_time
            mess= FailedMessage('Time-out waiting for cluster to reply "ready"');
            break;
        end
    end
end

[completed,obj] = obj.check_progress(mess);

if completed
    ok = false;
    info = sprintf('Parallel cluster: "%s" initialization have failed',...
        class(obj));

    if isa(mess.payload,'MException')
        info = sprintf('%s\n     Reason: %s',...
            info,mess.payload.getReport());
    elseif ~isempty(mess.fail_text)
        info = sprintf('%s\n     Reason: %s',...
            info,mess.fail_text);
    end

    obj = obj.display_progress(info,varargin{:});
else

    ok = true;
    obj.status = 'ready';
    info = sprintf('Parallel cluster "%s" is ready to execute tasks',...
        class(obj));
    obj = obj.display_progress(info,varargin{:});
end

end

function [obj,mess] = check_receive(obj)

try
    [ok,err,mess] = obj.mess_exchange_.receive_message(1,'ready');
catch ME
    info = sprintf('Parallel cluster: "%s" initialization have failed.',...
        class(obj));
    obj.status = FailedMessage(info,ME);
    info = sprintf('%s\n     Reason:\n\n %s',info,ME.getReport());
    obj.display_progress(info);
    rethrow(ME);
end

if isempty(mess)
    obj.status_changed_ = false;
end

if ok ~= MESS_CODES.ok
    info = sprintf('Can not receive message "ready". Reason: %s',...
        err);
    obj.display_progress(info);
    error('HERBERT:ClusterWrapper:runtine_error',info);
end

end