function obj=wait_started_and_report_(obj,check_time,varargin)
% check for 'ready' message and report cluster ready to user.
% if not ready for some reason, report the failure and
% diagnostics.
%
info = [ 'Waiting for parallel cluster: ',class(obj),' to start'];
state = StartingMessage();
state.payload = info;
obj.status = state;
obj = obj.display_progress(info ,varargin{:});
[obj,mess]=check_receive(obj);
started = ~isempty(mess);
while(~started)
    pause(check_time);
    [obj,mess] =check_receive(obj);
    obj = obj.display_progress();
    started = ~isempty(mess);
end

[completed,obj] = obj.check_progress(mess);
if completed
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
    obj.status = 'ready';
    info = sprintf('Parallel cluster "%s" is ready to accept jobs',...
        class(obj));
    obj = obj.display_progress(info,varargin{:});
end

function [obj,mess] = check_receive(obj)
try
    [ok,err,mess]=obj.mess_exchange_.receive_message(1,'ready');
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
    error('CLUSTER_WRAPPER:runtine_error',info);
end