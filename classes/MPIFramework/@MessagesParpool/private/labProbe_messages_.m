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

if isempty(task_nums) || (ischar(task_nums) && strcmpi(task_nums,'all'))
    task_nums = 1:obj.numLabs;
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
[isDataAvail,task_ids_from,tags] = labProbe();


if ~isDataAvail
    messages = {};
    task_ids_from = [];
    return;
end
%
%not_this = task_nums ~=obj.labIndex; % is it necessary possible?
selected = ismember(task_ids_from,task_nums);
if ~any(selected)
    messages = {};
    task_ids_from = [];
    return;
end
task_ids_from = task_ids_from(selected);
tags          = tags(selected);


if ~isempty(mess_tag)
    % check if tag is the tag requested or fail tag
    mess_requested = ((tags == mess_tag) | (tags == 0));
    if ~any(mess_requested)
        messages = {};
        task_ids_from = [];
        return;
    end
    task_ids_from  = task_ids_from(mess_requested);
    tags  = tags(mess_requested);
end
messages = MESS_NAMES.mess_name(tags);
