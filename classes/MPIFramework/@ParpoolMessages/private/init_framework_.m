function obj = init_framework_(obj,framework_info)
% Internal init_framework method, used to construct functional filebased
% message-exchange framework.
% Input:
%  framework_info -- either:
%             a) string, defining the job name (job_id)
%                 -- or:
%             b) the structure, defined by worker_job_info function:
%                in this case usually defines slave message exchange
%                framework.
%

if exist('framework_info','var')
    if isstruct(framework_info) && isfield(framework_info,'job_id')
        obj.job_id = framework_info.job_id;
    elseif(is_string(framework_info))
        obj.job_id = framework_info;
    else
        error('PARPOOL_MESSAGES:invalid_argument',...
            'inputs for init_framework function does not have correct structure')
    end
else
    error('PARPOOL_MESSAGES:invalid_argument',...
        'inputs for init_framework function is missing')
end

