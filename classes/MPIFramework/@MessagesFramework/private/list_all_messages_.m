function all_messages = list_all_messages_(obj,job_ids)
% list all messages belonging to the job and retrieve all their names
% for the lobs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.

all_messages = cell(numel(job_ids),1);

mess_folder = obj.exchange_folder;
folder_contents = dir(mess_folder);
if numel(folder_contents )==0
    return;
end
mess_template = 'mess_';
len = numel(mess_template);

is_mess = arrayfun(@(x)(~x.isdir && strncmpi(mess_template,x.name,len)),folder_contents);
mess_files = folder_contents(is_mess);
if numel(mess_files) ==0
    return;
end
mess_fnames = arrayfun(@(x)(strsplit(x.name,'_')),mess_files,'UniformOutput',false);

mess_names = arrayfun(@(x)(x{1}{2}),mess_fnames,'UniformOutput',false);
mess_id    = arrayfun(@(x)(sscanf(x{1}{3},'JobN%d.mat')),mess_fnames,'UniformOutput',true);


for id=1:numel(job_ids)
    correct_ind = ismember(mess_id,job_ids(id));
    if any(correct_ind)
        all_messages(id)=mess_names(correct_ind);
    end
end


