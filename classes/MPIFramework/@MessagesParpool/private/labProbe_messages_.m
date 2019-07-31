function [messages,task_ids_from] = labProbe_messages_(obj,task_nums,varargin)
% list all messages belonging to the job and retrieve all their names
% for the labs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
%

if ~exist('task_nums','var')
    task_nums = [];
end
n_labs = obj.numLabs;

if n_labs == 1
    messages = {};
    task_ids_from = [];
    return;
end
if isempty(task_nums) || (ischar(task_nums) && strcmpi(task_nums,'all'))
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
    lab_prober = @(nlab)(lab_prober_tag(nlab,mess_tag));
else
    lab_prober = @(nlab)(lab_prober_all_tags(nlab));
end
not_this  = task_nums ~= obj.labIndex;
task_nums = task_nums(not_this);
n_senders = numel(task_nums);
%
avail = false(1,n_senders);
res_tags  = -1*ones(1,n_senders);
for i=1:n_senders
    [avail(i),res_tags(i)] = lab_prober(task_nums(i));
end
task_ids_from  = task_nums (avail);
res_tags       = res_tags(avail);

messages       = MESS_NAMES.mess_name(res_tags);

function [avail,tag] = lab_prober_all_tags(lab_num)

[avail,~,tag] = labProbe(lab_num);
if ~avail
    tag = -1;
end

function [avail,tag_res] = lab_prober_tag(lab_num,tag)

% check requested message
[tag_avail,~,tag_req] = labProbe(lab_num,tag);
% check if fail message has been send from the lab specified
[fail_avail,~,tag_fail] = labProbe(lab_num,0);
avail = tag_avail | fail_avail;

tag_res = -1;
if fail_avail
    tag_res = tag_fail;
elseif tag_avail
    tag_res = tag_req;
end

