function obj = init_framework_(obj,framework_info)
% Internal init_framework method, used to construct functional filebased
% message-exchange framework.
% Input:
%  framework_info -- either:
%  a) string, defining the job name (job_id)
%     -- or:
%  b) the structure, defined by worker_job_info function:
%     in this case usually defines slave message exchange
%     framework.
%
%  If the control structure contains labID and numLabs, its assumed that
%  the framework is enabled in test mode, which means no real MPI
%  communications are enabled and message exchange is simulated.
%
%  Real MPI framework intialization structure should not contain labID and
%  numLabs fields. In this case, the labID and numLabs are taken from
%  parallel computing toolbox labnum and numlabs functions.
%
if exist('framework_info', 'var')
    if isstruct(framework_info) && isfield(framework_info,'job_id')
        obj.job_id = framework_info.job_id;
        if isfield(framework_info,'labID') % init Parpool framework in test mode
            obj.MPI_ = MatlabMPIWrapper(obj.interrupt_chan_tag_,...
                true,...
                framework_info.labID,framework_info.numLabs);
        end
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
if isempty(obj.MPI_)
    obj.MPI_ = MatlabMPIWrapper(obj.interrupt_chan_tag_,false);
end

