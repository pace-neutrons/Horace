function [messages,task_ids_from] = labProbe_messages_(obj,task_nums,varargin)
% list all messages belonging to the job and retrieve all their names
% for the labs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.
%
if ~exist('task_nums','var')
    task_nums = [];
end
n_labs = obj.numLabs;

if n_labs == 1
    messages = {};
    task_ids_from = [];
    % add persistent messages names to the messages, received from other labs
    [messages,task_ids_from] = obj.retrieve_interrupt(messages,task_ids_from,task_nums);
    return;
end
if isempty(task_nums) || (ischar(task_nums) && strcmpi(task_nums,'any'))
    task_nums = 1:n_labs;
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
    lab_prober = @(nlab)(lab_prober_tag(obj,nlab,mess_tag));
else
    lab_prober = @(nlab)(lab_prober_all_tags(obj,nlab));
end
not_this  = task_nums ~= obj.labIndex;
task_nums = task_nums(not_this);
%
[avail,res_tags] = arrayfun(lab_prober,task_nums);
task_ids_from  = task_nums (avail);
res_tags       = res_tags(avail);
%
messages       = MESS_NAMES.mess_name(res_tags);
if ~isempty(messages) && ~iscell(messages)
    messages = {messages};
end
% add persistent messages names to the messages, received from other labs
[messages,task_ids_from] = obj.retrieve_interrupt(messages,task_ids_from,task_nums);


function [avail,tag] = lab_prober_all_tags(obj,lab_num)

[avail,tag] = obj.MPI_.mlabProbe(lab_num,[]);
if ~avail
    tag = -1;
end

function [avail,tag_res] = lab_prober_tag(obj,lab_num,tag)
%
% check requested message
[mess_avail,tag_req] = obj.MPI_.mlabProbe(lab_num,tag);
% check if fail message has been send from the lab specified
i_tags = MESS_NAMES.instance().interrupt_tags;
for i=1:numel(i_tags)
    [fail_avail,tag_fail] = obj.MPI_.mlabProbe(lab_num,i_tags(i));
    if fail_avail
        break;
    end
end
avail = mess_avail | fail_avail;

tag_res = -1;
if fail_avail
    tag_res = tag_fail;
elseif mess_avail
    tag_res = tag_req;
end


