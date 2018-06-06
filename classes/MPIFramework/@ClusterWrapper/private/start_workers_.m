function [obj,completed] = start_workers_(obj,je_init_message,task_init_mess)
% send initialization information to each worker in the cluster and receive
% responce informing that the job has started
%
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
%

me = obj.mess_exchange_;
n_workers = obj.n_workers;
% clear up interactive pool if exist as this method will start
% batch job.
%
obj=obj.display_progress(['starting parallel job: ',obj.job_id]);
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

%
[ok,err,fin_mess] = me.receive_message(1,'started');
if ok~=MESS_CODES.ok
    error('CLUSTER_WRAPPER:runtime_error',...
        'Can not receive global "started" message from cluster, Err %s',...
        err);
end
[completed, obj] = obj.check_progress(fin_mess);
obj = obj.display_progress();


