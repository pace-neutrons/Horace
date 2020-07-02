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

persistent fixture_tags;
if isempty(fixture_tags)
    fixture_tags = MESS_NAMES.instance().pool_fixture_tags;
    fixture_tags = fixture_tags+obj.matalb_tag_shift_;
end
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
% if mess_tag requested is 'any' identify the tags of the existing
% messages looping over all possible tags
%
if mess_tag == -1 && ~isempty(tags_present)
    all_there = false(size(tags_present));
    
    % check interrupt channel first:
    the_tag = obj.interrupt_chan_tag_ + obj.matalb_tag_shift_;
    there = arrayfun(@(nlab)labProbeTag(obj,nlab,the_tag),source);
    all_there(there) = true;
    tags_present(there) = the_tag;
    if ~all(all_there) % check other tags
        for i=1:numel(fixture_tags)
            the_tag = fixture_tags(i);
            there = arrayfun(@(nlab)labProbeTag(obj,nlab,the_tag),source);
            all_there(there) = true;
            tags_present(there) = the_tag;
            if all(all_there)
                break;
            end
        end
    end
    tags_present(all_there) = tags_present(all_there)-obj.matalb_tag_shift_;
end

function present  = labProbeTag(obj,source,the_tag)
if obj.is_tested
    cache = obj.messages_cache_(source);
    the_tag = the_tag - obj.matalb_tag_shift_; % do not forget,
    %in test mode we are looking for MESS_NAMES tags, not Matlab-shifted tags
    present = find_tag_in_cache(cache,the_tag);
else
    present = labProbe(source,the_tag);
end
%
function present = find_tag_in_cache(cont,mess_tag)
% cache is not empty and some tags are present.
% find special tag in the cache.
%
if mess_tag == -1 %if any tag there, and is requested
    present = true; % Ugly but mimicks real Matlab MPI behaviour
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
%
function [present,tag_found]=check_task_id(obj,tid,mess_tag)
% check if single tag is present asking from single task.
% if tag == -1, true is returned if message with any tag is present.
%

if obj.is_tested
    if isKey(obj.messages_cache_,tid)
        cache = obj.messages_cache_(tid);
        present = find_tag_in_cache(cache,mess_tag);
        if present
            tag_found  = mess_tag;
        else
            tag_found = -1;
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

