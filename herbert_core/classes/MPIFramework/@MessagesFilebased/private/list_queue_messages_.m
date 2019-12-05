function [start_queue_num,free_queue_num]=list_queue_messages_(mess_folder,job_id,mess_name,send_from,sent_to)
% process list of the messages already sent from this routine and placed in
% a queue and return the numbers of the first message in the queue and
% the number of the  first free place in the queue
%
% Inputs:
% mess_folder -- full path to to the folder, containing messages.
% job_id      -- the string, defining the running job and used in error
%                reporting
% mess_name   -- the name of the messages in the queue
% send_from   -- the number of job (lab) the messages should be send
% sent_to     -- the number of job (lab) the messages should be directed.
% Outputs:
% start_queue_num -- the number of the first message to pop from the queue.
% free_queue_num  -- the number of the free space in the queue, i.e. the
%                    next message to pop in the queue.
%
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)
%
%
if ~(exist(mess_folder,'dir')==7) % job was canceled
    error('FILEBASED_MESSAGES:runtime_error',...
        'Job with id %s has been canceled. No messages folder exist',job_id)
end
folder_contents = get_folder_contents_(struct('task_id_',1),mess_folder);

[mess_names,mid_from,mid_to,fext] = parse_folder_contents_(folder_contents);
if isempty(mess_names) % no messages
    start_queue_num = -1;
    free_queue_num   = 0;
    return
end
this_name = cellfun(@(x)(strcmpi(x,mess_name)),mess_names,'UniformOutput',true);
% select the messages, which satisfy the request
these_mess = (mid_from == send_from) & (mid_to == sent_to) & (this_name);
mess_names = mess_names(these_mess);
if isempty(mess_names) % no messages
    start_queue_num = -1;
    free_queue_num   = 0;
    return
end
queue_list    = fext(these_mess);
queue_nums = cellfun(@convert2num,queue_list);
if numel(queue_nums) == 1 % the only queue file is .mat file. Reset queue counter to 0
    start_queue_num  = 0;
    free_queue_num   = 1;
    return
end
queue_nums = queue_nums(queue_nums>0);
start_queue_num = sort(queue_nums);
free_queue_num  = max(queue_nums)+1;

function num = convert2num(fext)
% convert message extension into queue number
if strcmpi(fext,'.mat')
    num=0;
else
    num = str2double(fext(2:end));
end

