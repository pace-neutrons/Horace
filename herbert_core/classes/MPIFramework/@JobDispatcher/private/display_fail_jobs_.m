function display_fail_jobs_(obj, outputs, n_failed, n_workers, err_code)
% Auxiliary method to display job results if the job has failed
%
% Input:
% outputs -- usually cellarray of the results, returned by a
%            parallel job
%
% n_failed -- number of tasks failed as the result of parallel
%             job
%
% n_workers-- number of labs used by parallel job initially
%
% err_code -- the text string in the form
%             ERROR_CLASS:error_reason to form identifier of
%             the exception to throw
%             If this parameter is empty, it does not throw anything.
% Throws:
% First exception returned from the cluster if such exceptions
% are present or exception with err_code as MException.identifier
% if no errors returned
%

debug_flag = get(parallel_config, 'debug');

if ~debug_flag
    log = sprintf("par_fail_%s.log", obj.job_id);
    fh = fopen(log, 'w');
    clob = onCleanup(@() fclose(fh));
end

if ~exist('err_code', 'var') || isempty(err_code)
    warn_code = 'HORACE:display_fail_jobs:parallel_failure';
else
    warn_code = err_code;
end

MExceptions_outputs = false(size(outputs));

if iscell(outputs)
    debug_print('Job %s failed. Outputs: \n', obj.job_id);

    for i=1:numel(outputs)
        if isa(outputs{i}, 'MException')
            MExceptions_outputs(i) = true;
            debug_print('Task %d failed. Error %s; Message %s\n', ...
                    i, outputs{i}.identifier, outputs{i}.message);

        elseif isfield(outputs{i}, 'error') && isa(outputs{i}.error, 'MException')
            MExceptions_outputs(i) = true;
            debug_print('Task %d failed. Reason: %s\n', ...
                i, outputs{i}.fail_reason);

        else
            MExceptions_outputs(i) = false;
            debug_print('Task %d failed. Outputs: \n', i);

            if isempty(outputs{i})
                debug_print('[]\n');
            else
                debug_print(disp2str(outputs{i}));
            end
        end
    end

elseif isempty(outputs)
    ext_type = class(outputs);
    debug_print('Job %s failed with unhandled exception: %s\n', obj.job_id, ext_type);

else

    MExceptions_outputs(1) = isa(outputs, 'MException');
    debug_print('Job %s failed. Output: \n', obj.job_id);
    debug_print(disp2str(outputs));

    if numel(outputs) == 1
        disp_exception(outputs);
    end

end

message = sprintf('%d of %d tasks in job %s have failed', ...
                  n_failed, n_workers, obj.job_id);

if isempty(outputs)
    message = [message, sprintf(' with unhandled exception: %s', ext_type)];

elseif any(MExceptions_outputs)

    err_outputs = outputs(MExceptions_outputs);

    if iscell(err_outputs)
        for i=1:numel(err_outputs)
            debug_print(['***** Error output N ', num2str(i)]);
            disp_exception(err_outputs{i});
        end
    else
        disp_exception(err_outputs);
    end

else
    message = [message, ' without returning the reason'];
end

if debug_flag
    error(err_code, '%s.', message);
else
    error(err_code, '%s, errors recorded in %s.', message, log)
end


function disp_exception(err_output)

if isa(err_output, 'MException')
    debug_print(disp2str(getReport(err_output)))

elseif iscell(err_output)

    for i=1:numel(err_output)
        debug_print(' Cell %d, contains: \n', i);
        disp_exception(err_output{i});
    end

elseif isfield(err_output, 'error') && isa(err_output.error, 'MException')

    for i=1:numel(err_output.error)
        debug_print('%s', disp2str(getReport(err_output.error(i))));
    end

else
    debug_print('unknown type of error: \n %s', disp2str(err_output));

end

end

function debug_print(varargin)
    if debug_flag
        fprintf(varargin{:});
    else
        fprintf(fh, varargin{:});
    end
end

end
