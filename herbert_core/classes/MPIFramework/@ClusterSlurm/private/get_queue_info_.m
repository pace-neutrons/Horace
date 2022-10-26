function queue_rows = get_queue_info_(obj,full_header)
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

queue_list = obj.get_queue_text_from_system(full_header);
queue_rows = splitlines(queue_list);
non_empty = ~cellfun(@isempty, queue_rows);
queue_rows = queue_rows(non_empty);
