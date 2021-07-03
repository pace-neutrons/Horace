function queue_rows = get_queue_info_(obj,full_header,trim_strings,for_this_job)
% returns existing jobs queue list by asking system for this list and
% parsing the list apporopriately
%
% Options:
% full_header  -- if true, job list should contain the header job list
%                 header
% trim_strings -- if true, the job list should be trimmed up to job
%                 run time infromation (for identifying existing jobs
%                 regardless of their run time)
% for_this_job -- if true, return log for job with this job_id only.
%                 job_id has to be defined

queue_list = obj.get_queue_text_from_system(full_header,for_this_job);
queue_rows = splitlines(queue_list);
if trim_strings
    queue_rows = cellfun(@(rw)trim_fun_(obj.log_parse_field_nums_(1),rw),...
        queue_rows,'UniformOutput',false);
end
non_empty = cellfun(@(rw)(~isempty(rw)),...
    queue_rows,'UniformOutput',true);
queue_rows  = queue_rows(non_empty);

function trimmed_row = trim_fun_(trim_cell_num,row)
% Function-helper to trim the rows, which are lurgher then the trim_size
cs = split(strtrim(row));
if numel(cs) > trim_cell_num
    trimmed_row = strjoin(cs(1:trim_cell_num),' ');
else
    trimmed_row = strjoin(cs,' ');
end

