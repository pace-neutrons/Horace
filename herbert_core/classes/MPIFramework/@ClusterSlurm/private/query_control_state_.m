function [squeue_state,sacct_state] = query_control_state_(obj,testing)
% retrieve the state of the job issuing Slurm control command and parsing
% the results
%
query = cell(2,1);
info   =cell(2,1);
result = cell(2,1);
if testing
    query{1} = 'squeue_command_output';
    query{2} = 'sacct_command_output';
else
    query{1} = sprintf('squeue --noheader -j %d',obj.slurm_job_id);
    query{2} = sprintf('sacct --noheader  -j %d --format=JobID,JobName,State,ExitCode',obj.slurm_job_id);
end
info{1} = 'squeue';
info{2} = 'sacct';

for i=1:2
    if testing
        res = obj.(query{i});
    else
        [fail,res] = system(query{i});
        if fail
            error('HERBERT:ClusterSlurm:runtime_error',...
                'Can not execute %s job %d state query. Error: %s',...
                info{i},obj.slurn_job_id,res);
        end
    end
    res = strsplit(strtrim(res));
    if numel(res)>1
        result{i} = res{obj.log_parse_field_nums_(i)};
    else
        result{i} = '_';
    end
end

squeue_state = obj.qjob_sf_substitution(result{1});
sacct_state  = result{2};
sacct_state  = sacct_state(1:2);
