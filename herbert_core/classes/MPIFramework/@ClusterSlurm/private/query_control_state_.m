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
    query = [sprintf('sacct --noheader  -j %d ',obj.slurm_job_id),...
        '--format=JobID,JobName%50,State,ExitCode'];
end


if testing
    res = obj.(query);
else
    [fail,res] = system(query);
    if fail
        error('HERBERT:ClusterSlurm:runtime_error',...
            'Can not execute sacct query for job %d state Error: %s',...
            obj.slurn_job_id,res);
    end
end
res = strsplit(strtrim(res));
if numel(res)>1
    % the state stored in field N3 out of 4 requested
    full_state = res{3};
else % should not ever happen. Only invalid jobID may lead to this.
    full_state = '__';
end

sacct_state  = full_state(1:2);
