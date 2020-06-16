function [messages,task_ids_from] = labProbe_messages_(obj,task_ids,varargin)
% list all messages belonging to the job and retrieve all their names
% for the labs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.
%
% Will check if interupt is availabe and if it is,
%
if ~exist('task_ids','var')
    task_ids = [];
end
%n_labs = obj.numLabs;
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
    [messages,task_ids_from] = obj.MPI_.mlabProbe(task_ids,[]);
end
i_tags = MESS_NAMES.instance().interrupt_tags;
for i=1:numel(i_tags)
    [fail_mess,fail_from] = obj.MPI_.mlabProbe(task_ids,i_tags(i));
    if ~isempty(fail_mess)
        [messages,task_ids_from] = obj.mix_messages(messages,task_ids_from,fail_mess,fail_from);
    end
end

[mess,id_from] = obj.get_interrupt(task_ids);
% mix received messages names with old interrupt names received earlier and
% hold in cache
if ~isempty(mess)
    int_names = cellfun(@(x)(x.mess_name),mess,'UniformOutput',false);
    [messages,task_ids_from] = ...
        obj.mix_messages(messages,task_ids_from,int_names,id_from);
end

