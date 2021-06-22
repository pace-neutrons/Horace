function obj = extract_job_id_(obj,old_queue_rows)
% Retrieve job queue logs from the system 
% and extract new job ID from the log
%
% Inputs:
% old_queue_rows -- the cellarray of rows, which contains the
%                   job logs, obtained before new job was
%                   submitted
%
new_job_id_found = false;
while ~new_job_id_found
    pause(obj.time_to_wait_for_job_id_);
    new_queue_rows = obj.get_queue_info('-trim');
    old_rows = ismember(new_queue_rows,old_queue_rows);
    if ~all(old_rows)
        new_job_id_found = true;
    end
end
new_job_info = new_queue_rows(~old_rows);
if numel(new_job_info) > 1
    % ask user to select a job interactively
    new_job_info = select_job_interactively_(new_job_info);
end
job_comp = strsplit(strtrim(new_job_info{1}),...
    {' ','\f','\n','\r','\t','\v'},'CollapseDelimiters',true);
obj.slurm_job_id_ = str2double(job_comp{1});
