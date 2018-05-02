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

if isempty(task_nums)
    task_nums = 1:obj.numLabs;
end
%
if nargin > 2
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
%
not_this = task_nums ~=obj.labIndex;
task_nums = task_nums(not_this);

num_tasks = numel(task_nums);
messages  = cell(1,num_tasks );
task_ids_from   = zeros(1,num_tasks);
num_present = 0;
for i=1:num_tasks
    if isempty(mess_tag)
        [isDataAvail,id,tag] = labProbe(task_nums(i));        
    else
        [isDataAvail,id,tag] = labProbe(task_nums(i),mess_tag);
    end
    if isDataAvail
        messages{i} = MESS_NAMES.mess_name(tag);
        task_ids_from(i) = id;
        num_present = num_present +1;
    end
end
if num_present == 0
    messages = {};
    task_ids_from = [];
else
    present = task_ids_from ~= 0;
    if any(~present)
        messages = messages(present);
        task_ids_from = task_ids_from(present);
    end
end

