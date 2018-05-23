function [messages,task_ids_from] = labProbe_messages_(obj,task_nums,varargin)
% list all messages belonging to the job and retrieve all their names
% for the lobs with id, provided as input.
% if no message is returned for a job, its name cell remains empty.
if ~exist('task_nums','var')
    task_nums = [];
end
% there is bug in Matlab code parser which fails when this is enabled for
% parallel toolbox
% if nargin>2 % tester mode provides non-omp labprobe function
%     if ~isempty(varargin)
%         labProbe = varargin{1};
%     end
% end
n_labs = obj.numLabs;
if n_labs == 1
    messages = {};
    task_ids_from = [];
    return;
end
if isempty(task_nums) || (ischar(task_nums) && strcmpi(task_nums,'all'))
    task_nums = 1:n_labs;
end
%
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
else
    mess_tag = [];
end
not_this  = task_nums ~= obj.labIndex;
task_nums = task_nums(not_this);
n_senders = numel(task_nums);
%
avail = false(1,n_senders);
res_tags  = -1*ones(1,n_senders);
for i=1:n_senders
    [avail(i),~,avail_tags] = labProbe(task_nums(i));
    if ~avail(i)
        continue
    end
    
    if ~isempty(mess_tag) %select the tags requested
        % fail message is always requested
        mess_requested = (avail_tags == mess_tag) | (avail_tags == 0);
        avail_tags = avail_tags(mess_requested);
        if ~any(avail_tags)
            avail(i) = false;
            continue
        end        
    end
    res_tags(i) = avail_tags(1);
    
end

task_ids_from  = task_nums (avail);
res_tags       = res_tags(avail);

messages       = MESS_NAMES.mess_name(res_tags);

