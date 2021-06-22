function queue_text = get_queue_text_from_system_(obj,full_header,job_with_this_id)
% retrieve queue information from the system
% Input keys:
% full_header -- if true, job information should contain header
%                describing the fields. if talse, only the
%                job information itself is returned
%job_with_this_id -- return information for the job with this
%               id only. If false, all jobs for this users are
%               returned.
if job_with_this_id
    if full_header
        query = sprintf('squeue --name=%d',obj.slurn_job_id);
    else
        query = sprintf('squeue --noheader  --name=%d',obj.slurn_job_id);
    end
    [fail,queue_text] = system(query);
else
    if full_header
        [fail,queue_text] = system(['squeue --user=',obj.user_name_]);
    else
        [fail,queue_text] = system(['squeue --noheader --user=',...
            obj.user_name_]);
    end
end
if fail
    error('HERBERT:ClusterSlurm:runtime_error',...
        ' Can not execute slurm queue query. Error: %s',...
        queue_text);
end
