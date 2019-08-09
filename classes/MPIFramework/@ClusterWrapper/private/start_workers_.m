function obj = start_workers_(obj,je_init_message,task_init_mess,log_prefix)
% send initialization information to each worker in the cluster and receive
% response informing that the job has started
%
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%


me = obj.mess_exchange_;
n_workers = obj.n_workers;
% clear up interactive pool if exist as this method will start
% batch job.
%
n_locked = 0;
wlock_obj_arr = cell(1,n_workers);
obj=obj.display_progress([log_prefix,' parallel job: ',obj.job_id]);
for tid=1:n_workers
    [ok,err,wlock] = me.send_message(tid,je_init_message);
    if ok ~= MESS_CODES.ok
        if ~isempty(wlock)
            n_locked = n_locked+1;
            wlock_obj_arr{n_locked}= wlock;
        else
        error('CLUSTER_WRAPPER:runtime_error',...
            ' Can not send starting message for job %s, worker %d; Error: %s',...
            me.job_id,tid,err);
        end
    end
end
if n_locked > 0
    for i=1:n_locked
        wlock_clerner = wlock_obj_arr{i};
        wlock_clerner();
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




