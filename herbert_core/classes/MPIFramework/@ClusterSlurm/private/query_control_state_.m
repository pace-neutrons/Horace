function [sacct_state,full_state] = query_control_state_(obj,testing)
% retrieve the state of the job issuing Slurm sacct query command
% and parsing the results
%
%
if testing
    query = 'sacct_command_output';
else
    % requesting 4 fields with field "State" (field N3) requested. Others
    % are useful for debugging purposes
    query = sprintf('sacct --noheader -j %d --format=JobID,JobName%%50,State,ExitCode',obj.slurm_job_id);
end

if testing
    full_state = obj.(query);
else
    [fail,full_state] = system(query);
    if fail
        error('HERBERT:ClusterSlurm:runtime_error',...
            'Can not execute sacct query for job %d state Error: %s',...
            obj.slurm_job_id,full_state);
    end
end

res = strsplit(strtrim(full_state));

if numel(res) > 1
    % the state stored in field N3 out of 4 requested
    sacct_state = res{3};
else % should not ever happen. Only invalid jobID may lead to this.
    sacct_state = '__';
end

sacct_state = sacct_state(1:2);
