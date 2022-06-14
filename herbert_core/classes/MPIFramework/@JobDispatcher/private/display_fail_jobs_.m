function    display_fail_jobs_(obj,outputs,n_failed,n_workers,Err_code)
% Auxiliary method to display job results if the job have
% failed
% Input:
% Outputs -- usually cellarray of the results, returned by a
%            parallel job
% n_failed -- number of tasks failed as the result of parallel
%             job
% n_workers-- number of labs used by parallel job initially
%
% Err_code -- the text string in the form
%             ERROR_CLASS:error_reason to form identifier of
%             the exception to throw
%             If this paraemter is empty, it does not throw anything.
% Throws:
% First exception returned from the cluster if such exceptions
% are present or exception with Err_code as MExeption.identifier
% if no errors returned
%

mEXceptions_outputs = false(size(outputs));
if iscell(outputs)
    fprintf('Job %s have failed. Outputs: \n',obj.job_id);
    for i=1:numel(outputs)
        if isa(outputs{i},'MException')
            mEXceptions_outputs(i) = true;
            fprintf('Task N%d failed. Error %s; Message %s\n',...
                i,outputs{i}.identifier,outputs{i}.message);
        elseif isfield(outputs{i},'error') && isa(outputs{i}.error,'MException')
            mEXceptions_outputs(i) = true;
            fprintf('Task N%d failed. Reason: %s\n',...
                i,outputs{i}.fail_reason);
            
        else
            mEXceptions_outputs(i) = false;
            fprintf('Task N%d failed. Outputs: \n',i);
            if isempty(outputs{i})
                fprintf('[]\n');
            else
                disp(outputs{i});
            end
        end
    end
elseif isempty(mEXceptions_outputs)
    ext_type = class(outputs);
    fprintf('Job %s have failed sending unhandled exception: %s\n',obj.job_id,ext_type);
    if ~isempty(Err_code)
        error(Err_code,'Parallel job have failed throwing unhandled exception: %s',ext_type);
    end
else
    mEXceptions_outputs(1) = isa(outputs,'MException');
    fprintf('Job %s have failed. Output: \n',obj.job_id);
    disp(outputs);
    if numel(outputs) == 1
        disp_exception(outputs);
    end
end
if any(mEXceptions_outputs)
    if isempty(Err_code)
        warn_code = 'DISPLAY_FAIL_JOBS:parallel_failure';
    else
        warn_code = Err_code;
    end
    warning(warn_code ,...
        ' Number: %d parallel tasks out of total: %d tasks have failed',...
        n_failed,n_workers)
    errOutputs = outputs(mEXceptions_outputs);
    if iscell(errOutputs)
        for i=1:numel(errOutputs)
            disp(['***** Error output N ',num2str(i)]);
            disp_exception(errOutputs{i});
        end
    else
        disp_exception(errOutputs);
    end
    if ~isempty(Err_code)
        error(Err_code,'Parallel job have failed, producing errors above.');
    end
else
    if ~isempty(Err_code)
        error(Err_code,...
            ' Number: %d parallel tasks out of total: %d tasks have failed without returning the reason',...
            n_failed,n_workers)
    end
end

function disp_exception(errOutput)
%
if isa(errOutput,'MException')
    disp(getReport(errOutput))
elseif iscell(errOutput)
    disp('***************************************************************');
    disp(errOutput);
    for i=1:numel(errOutput)
        sprintf(' Cell %d, contains: %s\n',i,evalc('disp(errOutput{i}'));
        disp_exception(errOutput{i});
    end
    disp('***************************************************************');
elseif isfield(errOutput,'error') && isa(errOutput.error,'MException')
    for i=1:numel(errOutput.error)
        disp(getReport(errOutput.error(i)));
    end
else
    disp('unknown type of error returned')
end


