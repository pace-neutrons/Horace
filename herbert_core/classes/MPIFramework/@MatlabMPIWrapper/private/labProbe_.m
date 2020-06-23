function [tags_present,source]=labProbe_(obj,task_id,mess_tag)
% Wrapper around Matlab labProbe command.
% Checks if specific message is available on the system
%
% Inputs:
% task_id  - the address of lab to ask for information
%            if empty, any task_id
% mess_tag - if ~=-1, check for specific message tag
% Returns:
% tags_present - the tag of the present information block or
%               empty if no messages are present
% source   - the lab-id-s of the tasks, where the messages are present

%
if ischar(task_id)
    if strcmp(task_id,'all') ||strcmp(task_id,'any')
        task_id = [];
    else
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'Unknown source address %s',task_id)
    end
end
tags_present = [];
if isempty(task_id)
    task_id = 1:obj.numLabs;
end
non_this = task_id ~=obj.labIndex;
task_id = task_id(non_this);
if isempty(task_id)
    source = [];
    return;
end
[are_present,all_tags] = arrayfun(@(x)check_task_id(obj,x,mess_tag),task_id,...
    'UniformOutput',true);
tags_present = all_tags(are_present);
source = task_id(are_present);


function [present,tag_found]=check_task_id(obj,tid,mess_tag)
if obj.is_tested
    if isKey(obj.messages_cache_,tid)
        present = true;
        cont = obj.messages_cache_(tid);
        if mess_tag == -1
            tag_found = mess_tag; % Ugly but mimicks real Matlab MPI behaviour
        else
            present = false;
            for i=1:numel(cont)
                mess_cont = cont{i};
                tag_found = mess_cont.tag;
                
                if tag_found == mess_tag
                    present  = true;
                    return;
                end
            end
        end
    else
        tag_found= -1;
        present = false;
    end
else
    if mess_tag == -1
        present = labProbe(tid);
        tag_found = -1;
    else
        matlab_tag = mess_tag+obj.matalb_tag_shift_;
        present = labProbe(tid,matlab_tag);
        if present
            tag_found = mess_tag;
        else
            tag_found = -1;
        end
    end
end

