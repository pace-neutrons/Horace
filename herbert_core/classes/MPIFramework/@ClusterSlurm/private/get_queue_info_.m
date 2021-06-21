function queue_rows = get_queue_info_(obj,full_header,trim_strings)
% returns existing jobs queue list by asking system for this list and
% parsing the list apporopriately
%
% Options:
% full_header  -- if true, job list should contain the header job list
%                 header
% trim_strings -- if true, the job list should be trimmed up to job
%                 run time infromation (for identifying existing jobs
%                 regardless of their run time)

queue_list = obj.get_queue_text_from_system(full_header);
queue_rows = strsplit(queue_list,{'\n','\r'},'CollapseDelimiters',true);
if trim_strings
    queue_rows = cellfun(@(rw)trim_fun_(obj.time_field_pos_,rw),...
        queue_rows,'UniformOutput',false);
end
non_empty = cellfun(@(rw)(~isempty(rw)),...
    queue_rows,'UniformOutput',true);
queue_rows  = queue_rows(non_empty);

function trimmed_row = trim_fun_(trim_size,row)
% Function-helper to trim the rows, which are lurgher then the trim_size
if numel(row)<trim_size
    trimmed_row = row;
    return
end
trimmed_row = row(1:trim_size);

