function  [completed,ok,mess] = check_job_completed_(process)
% check if the process is still running or has been completed
completed = false;
mess = '';
try
    term = process.exitValue();
    completed = true;
    if term == 0
        ok = true;
    else
        ok = false;
    end
catch Err
    if strcmp(Err.identifier,'MATLAB:Java:GenericException')
        part = strfind(Err.message,'process has not exited');
        if isempty(part)
            mess = Err.message;
            ok = false;
            completed  = true;
        else
            ok = true;
        end
    else
        rethrow(Err);
    end
end

