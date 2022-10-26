function sacct_state = check_pending_state_(obj,sacct_state)
% the partially completed function, which checks state from squeue & sinfo
% and decides if treat pending state as failed.

query = sprintf('squeue -j %d --noheader --format="%.2t %.6D %R"',obj.slurm_job_id);
reply = ask_system(obj,query);

if isempty(reply)
    rep_fields = {''};
else
    rep_fields = strsplit(reply);
end

if numel(rep_fields)>3
    rep_fields{3} = strjoin(rep_fields(3:end),' ');
end

if obj.log_level > -1
    info = ask_system(obj,'sinfo');
    fprintf(2,'*** *****************************************************\n')
    fprintf(2,'*** Encountering pending state submitting job to cluster:\n')
    fprintf('*** sinfo returns:\n %s\n',info)
    fprintf(2,'*** *****************************************************\n')
end

if strcmp(rep_fields{1},'PD')
    fail_kw = {'Resources','DOWN','DRAINED','ReqNodeNotAvail','higher priority','Priority'};
    is_fail = cellfun(@(fkw)contains(rep_fields{3},fkw),fail_kw,...
        'UniformOutput',true);
    if any(is_fail)
        sacct_state='PD';
        if obj.log_level>-1
            fprintf(2,'*** Job requested %s Nodes: Nodelist(REASON):\n',rep_fields{2})
            fprintf(2,'*** %s\n',rep_fields{3})
        end

    end
end

end

function reply = ask_system(obj,query)

if isprop(obj,'squeue_command_output')
    % testing mode
    reply = obj.squeue_command_output;
else
    [fail,full_state] = system(query);
    if fail
        error('HERBERT:ClusterSlurm:runtime_error',...
            'Can not execute sacct query for job %d state Error: %s',...
            obj.slurn_job_id,full_state);
    end
    reply  = strtrim(full_state);
end

end