function [all_messages,mid_from] = find_messages_with_name_(obj,task_ids_requested,mess_name,allow_locked)
% find if message with the name provided as input sent to this lab from
% the lab with the id-s specified as input are present on file system
%
% if allow_locked == false, ignore messages which are locked
%
%
lab_num = obj.labIndex;
mess_files_list = arrayfun(@(tid)job_stat_fname_(obj,lab_num,mess_name,tid,false),...
    task_ids_requested,'UniformOutput',false);
%
% check if the messages are indeed present
mess_present = cellfun(@(fn)(is_file(fn)),mess_files_list,...
    'UniformOutput',true);
mid_from = task_ids_requested(mess_present);
if allow_locked || isempty(mid_from)
    all_messages =  arrayfun(@(x)(mess_name),1:sum(mess_present),'UniformOutput',false);
    return;
end
%

mess_files_list = mess_files_list(mess_present);
mess_present    = true(size(mess_files_list));
nolocked = cellfun(@(fn)check_nolocked(fn),mess_files_list,...
    'UniformOutput',true);
mid_from     =  mid_from(nolocked);
mess_present = mess_present(nolocked);
all_messages =  arrayfun(@(x)(mess_name),1:sum(mess_present),'UniformOutput',false);

end

function no = check_nolocked(filename)
% check if given file is not locked
[rlock,wlock] = build_lock_fname_(filename);

no = ~(is_file(rlock) || is_file(wlock));

end
