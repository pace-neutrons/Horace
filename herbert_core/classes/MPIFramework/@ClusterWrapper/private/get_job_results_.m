function   [outputs,n_failed,obj] = get_job_results_(obj)
% retrieve parallel job results

if isempty(obj.current_status_)
    error('CLUSTER_WRAPPER:runtime_error',...
        'can not get job results, retrieve results from cluster first')
end

me_out = obj.current_status_;
if isequal(me_out.mess_name,'failed')
    if iscell(me_out.payload)
        is_fail = cellfun(@is_err,me_out.payload,'UniformOutput',true);
        n_failed = sum(is_fail);
    else        
        n_failed = obj.n_workers;
    end
else
    n_failed = 0;
end
outputs = me_out.payload;

function is = is_err(x)
if isa(x,'MException') || isa(x,'ParallelException')
    is = true;
elseif iscell(x)
    is_fail = cellfun(@is_err,x,'UniformOutput',true);
    is = any(is_fail);
else
    is =  isstruct(x) && isfield(x,'error') && isa(x.error,'MException');
end
