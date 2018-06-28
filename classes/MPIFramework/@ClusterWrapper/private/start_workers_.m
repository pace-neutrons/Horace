function obj = start_workers_(obj,je_init_message,task_init_mess,log_prefix)
% send initialization information to each worker in the cluster and receive
% response informing that the job has started
%
%
% $Revision$ ($Date$)
%


me = obj.mess_exchange_;
n_workers = obj.n_workers;
% clear up interactive pool if exist as this method will start
% batch job.
%

obj=obj.display_progress([log_prefix,' parallel job: ',obj.job_id]);
for tid=1:n_workers
    [ok,err] = me.send_message(tid,je_init_message);
    if ok ~= MESS_CODES.ok
        error('CLUSTER_WRAPPER:runtime_error',...
            ' Can not send starting message for job %s, worker %d; Error: %s',...
            me.job_id,tid,err);
    end
end

for tid=1:n_workers
    [ok,err] = me.send_message(tid,task_init_mess{tid});
    if ok ~= MESS_CODES.ok
        error('CLUSTER_WRAPPER:runtime_error',...
            ' Can not send init message for job %s, worker %d; Error: %s',...
            me.job_id,tid,err);
    end
end




