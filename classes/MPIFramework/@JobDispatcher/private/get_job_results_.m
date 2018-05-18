function   [outputs,n_failed,obj] = get_job_results_(obj)
% retrieve parallel job results

mf = obj.mess_framework;
% Also would receive "failed" message
[ok,err,mess] = mf.receive_message(1,'completed');
if ok ~= MESS_CODES.ok
    error('JOB_DISPATCHER:runtime_error',...
        'Can not receive ''completed'' message, Error %s',err);
end

outputs = mess.payload;
n_failed = 0;
if strcmpi(mess.mess_name,'failed')
    for i=1:numel(outputs)
        if isa(outputs{i},'FailMessage')
            n_failed  = n_failed +1;
        end
    end
end
