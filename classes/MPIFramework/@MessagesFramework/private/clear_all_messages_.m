function   clear_all_messages_(obj,mess_template)
%
% delete all messages, in the exchange folder, which satisfy the message template
%

mess_folder = obj.exchange_folder;
folder_contents = dir(mess_folder);
if numel(folder_contents )==0
    return;
end
len = numel(mess_template);

is_mess = arrayfun(@(x)(~x.isdir && strncmpi(mess_template,x.name,len)),folder_contents);
mess_files = folder_contents(is_mess);
if numel(mess_files) ==0
    return;
end
mess_fnames = arrayfun(@(x)(fullfile(mess_folder,x.name)),mess_files,'UniformOutput',false);

delete(mess_fnames{:});