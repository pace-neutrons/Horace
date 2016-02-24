function  str  = state2str_(obj)
% Convert logical state of the job into string representation
%
if obj.is_starting
    str = 'starting';
elseif obj.is_running
    if obj.reports_progress
        str = 'running';
    else
        str = 'started';
    end
elseif obj.is_finished
    str = 'completed';
elseif obj.is_failed
    str = 'failed';
else
    str = 'ERR:undef';
end
