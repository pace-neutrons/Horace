function queue_text = get_queue_text_from_system_(obj,full_header)
% retrieve queue information from the system
%
% Input keys:
% full_header -- if true, job information should contain header
%                describing the fields. if talse, only the
%                job information itself is returned
if full_header
    query = sprintf('squeue --user=%s --format="%.18i %.9P %.8j %.8u %.2t"',obj.user_name_);

else
    query = sprintf('squeue --noheader --user=%s --format="%.18i %.9P %.8j %.8u %.2t"',obj.user_name_);    
end

[fail,queue_text] = system(query);
if fail
    error('HERBERT:ClusterSlurm:runtime_error',...
        ' Can not execute slurm queue query. Error: %s',...
        queue_text);
end
queue_text = strtrim(queue_text);