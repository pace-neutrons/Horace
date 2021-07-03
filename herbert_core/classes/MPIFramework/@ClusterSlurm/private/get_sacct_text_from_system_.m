function sacct_out = get_sacct_text_from_system_(obj,full_header)
% retrieve queue information from the system
% Input keys:
% full_header -- if true, job information should contain header
%                describing the fields. if talse, only the
%                job information itself is returned
% Returns:
% sacct_out   -- the text, describing the state of the job
%                (sacct command output)

if full_header
    query = sprintf('sacct -j%d',obj.slurn_job_id);
else
    query = sprintf('sacct --noheader  -j%d',obj.slurn_job_id);
end
[fail,sacct_out] = system(query);
if fail
    error('HERBERT:ClusterSlurm:runtime_error',...
        ' Can not execute sacct job %d state query. Error: %s',...
        obj.slurn_job_id,sacct_out);
end
sacct_out = strtrim(sacct_out);
