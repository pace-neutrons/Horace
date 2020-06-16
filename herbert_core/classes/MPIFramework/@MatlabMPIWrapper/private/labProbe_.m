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
    if strcmp(task_id,'all')
        task_id = [];
    else
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'Unknown source address %s',task_id)
    end
end
tags_present = [];
if obj.is_tested
    if isempty(task_id)
        if obj.messages_cache_.Count==0
            source = [];
            return
        end
        kk = obj.messages_cache_.keys;
        tags_present = zeros(1,numel(kk));
        source      = zeros(1,numel(kk));
        for i=1:numel(kk)
            cont = obj.messages_cache_(kk{i});
            mess_cont = cont{1};
            source(i) = kk{i};
            tags_present(i) = mess_cont.tag;
        end
        if mess_tag ~=-1
            tag_correct = tags_present == mess_tag;
            tags_present = tags_present(tag_correct);
            source = source(tag_correct);
        end
    else
        [are_present,all_tags] = arrayfun(@(x)check_task_id(obj,x,mess_tag),task_id,...
            'UniformOutput',true);
        tags_present = all_tags(are_present);
        source = task_id(are_present);
        
    end
else % Real MPI request
    if isempty(task_id)
        [present,source,matlab_tag_present] = labProbe;
        if present
            tags_present = matlab_tag_present-obj.matalb_tag_shift_;
        else
            source = [];
        end
    else
        if mess_tag == -1
            [present,source,matlab_tag_present] = labProbe;
            if present
                tags_present = matlab_tag_present-obj.matalb_tag_shift_;
                from_req = source ==  task_id;
                if any(from_req)
                    source  = source(from_req);
                    tags_present = tags_present(from_req);
                else
                    source = [];
                end
            end
        else
            [are_present,all_tags] = arrayfun(@(x)check_task_id(obj,x,mess_tag),task_id,...
                'UniformOutput',true);
            tags_present = all_tags(are_present);
            source = task_id(are_present);
        end
    end
end

function [present,mess_tag]=check_task_id(obj,tid,mess_tag)
if obj.is_tested
    if isKey(obj.messages_cache_,tid)
        present = true;
        cont = obj.messages_cache_(tid);
        mess_cont = cont{1};
        tag_present = mess_cont.tag;
        if mess_tag ~= -1
            if tag_present == mess_tag
                present = true;
                return;
            else
                mess_tag= 0;
                present = false;
            end
        end
    else
        mess_tag= 0;
        present = false;
    end
else
    matlab_tag = mess_tag+obj.matalb_tag_shift_;
    present = labProbe(tid,matlab_tag);
    if ~present
        mess_tag = 0;
    end
end

