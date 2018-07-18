function [start_queue_num,free_queue_num]=list_these_messages_(obj,mess_name,send_from,sent_to)
% process list of the messages already sent from this routine
% and return the numbers of the first message in the queue and the number of the
% first free place in the queue

mess_folder = obj.mess_exchange_folder;
folder_contents = dir(mess_folder);
if numel(folder_contents )<=2 % no messages in the folder
    start_queue_num = -1;
    free_queue_num   = 0;
    if ~(exist(mess_folder,'dir')==7) % job was cancelled
        error('FILEBASED_MESSAGES:runtime_error',...
            'Job with id %s has been cancelled. No messages folder exist',obj.job_id)
    end
    return;
end
[mess_names,mid_from,mid_to,fext] = parce_folder_contents_(folder_contents);
if isempty(mess_names) % no messages
    start_queue_num = -1;
    free_queue_num   = 0;
    return
end
this_name = cellfun(@(x)(strcmpi(x,mess_name)),mess_names,'UniformOutput',true);
these_mess = (mid_from == send_from) & (mid_to == sent_to) & (this_name);
mess_names = mess_names(these_mess);
if isempty(mess_names) % no messages
    start_queue_num = -1;
    free_queue_num   = 0;
    return
end
queue_list    = fext(these_mess);
queue_nums = cellfun(@convert2num,queue_list);
if numel(queue_nums) == 1
    start_queue_num  = 0;
    free_queue_num   = 1;
    return
end
queue_nums = queue_nums(queue_nums>0);
start_queue_num = min(queue_nums);
free_queue_num  = max(queue_nums)+1;

function num = convert2num(fext)
% convert message extension into queue number
if strcmpi(fext,'.mat')
    num=0;
else
    num = str2double(fext(2:end));
end
