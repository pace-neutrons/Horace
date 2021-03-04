function [messages,task_ids_from] = labProbe_messages_(obj,task_ids,varargin)
% probe messages send to this lab and retrieve their names. 
% 
% Return list of the message names and array of task id-s which sent
% messages. 
%
% Will check if interrupt is available and if it is, return interrupt name 
% instead of any other message.
%
if ~exist('task_ids', 'var')
    task_ids = [];
end
if isnumeric(task_ids) && ~isempty(task_ids)
    not_this  = task_ids ~= obj.labIndex;
    task_ids  = task_ids(not_this);
end

% check if specific message name is requested
if nargin > 2 && ~isempty(varargin{1})
    mess_name = varargin{1};
    if ischar(mess_name)
        mess_tag = MESS_NAMES.mess_id(mess_name);
    elseif isnumetic(mess_name)
        is_valid = MESS_NAMES.tag_valid(mess_name);
        if is_valid
            mess_tag = mess_name;
        else
            error('PARPOOL_MESSAGES:invalid_argument',...
                'invalid message tag %d requested in labProbe',...
                mess_name);
        end
    else
        error('PARPOOL_MESSAGES:invalid_argument',...
            'unrecognized message name type');
    end
    if numel(mess_tag) > 1
        error('PARPOOL_MESSAGES:invalid_argument',...
            'labprobe with tag accepts only one message type')
    end
    [messages,task_ids_from] = obj.MPI_.mlabProbe(task_ids,mess_tag);
    
else
    [messages,task_ids_from] = obj.MPI_.mlabProbe(task_ids,-1);
end
% Add to the list of present messages the messages from interrupt channel
% if interrupt present, the message overtakes normal message from the same
% lab.
i_tags = obj.interrupt_chan_tag_;
[fail_mess,fail_from] = obj.MPI_.mlabProbe(task_ids,i_tags);
if ~isempty(fail_mess)
    [messages,task_ids_from] = obj.mix_messages(messages,task_ids_from,fail_mess,fail_from);
end

% check the interrupts, received earlier.
[mess,id_from] = obj.get_interrupt(task_ids);
% mix received messages names with old interrupt names received earlier and
% hold in cache
if ~isempty(mess)
    int_names = cellfun(@(x)(x.mess_name),mess,'UniformOutput',false);
    [messages,task_ids_from] = ...
        obj.mix_messages(messages,task_ids_from,int_names,id_from);
end

