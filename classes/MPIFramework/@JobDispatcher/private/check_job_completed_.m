function  [completed,ok,mess] = check_job_completed_(process,test_contents)
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
        mess = fprintf('Startup error with ID: %d',term);
    end
catch Err
    if strcmp(Err.identifier,'MATLAB:Java:GenericException')
        part = strfind(Err.message,test_contents);
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

