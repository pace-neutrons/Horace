function [present,tag_present,source]=labProbe_(obj,task_id,mess_tag)
% Wrapper around Matlab labProbe command.
% Checks if specific message is available on the system
%
% Inputs:
% task_id  - the address of lab to ask for information
%            if empty, any task_id
% mess_tag - if ~=-1, check for specific message tag
% Returns:
% present  - true if requested information is available
% tag_present - the tag of the present information block or
%            empty if present is false
% source   - in most cases equal to task id, but if any task
%            id, the information on where the data are present
%
source = task_id;
tag_present = [];
if obj.is_tested
    if isempty(task_id)
        if obj.messages_cache_.Count==0
            present = false;
            return
        end
        kk = obj.messages_cache_.keys;
        present = true;
        tag_present = zeros(1,numel(kk));
        source      = zeros(1,numel(kk));
        for i=1:numel(kk)
            cont = obj.messages_cache_(kk{i});
            mess_cont = cont{1};
            source(i) = kk{i};
            tag_present(i) = mess_cont.tag;
        end
    else
        if isKey(obj.messages_cache_,task_id)
            present = true;
            cont = obj.messages_cache_(task_id);
            mess_cont = cont{1};
            tag_present = mess_cont.tag;
            if mess_tag ~= -1
                if tag_present == mess_tag
                    return;
                else
                    present = false;
                end
            end
        else
            present = false;
        end
    end
else % Real MPI request
    if isempty(task_id)
        [present,source,matlab_tag_present] = labProbe;
        tag_present = matlab_tag_present-obj.matalb_tag_shift_;
    else
        if mess_tag == -1
            [present,source,matlab_tag_present] = labProbe;
            if present
                tag_present = matlab_tag_present-obj.matalb_tag_shift_;
                from_req = source ==  task_id;
                if any(from_req)
                    present = true;
                    source  = source(from_req);
                    tag_present = tag_present(from_req);
                else
                    present = false;
                end
            end
        else
            matlab_tag = mess_tag+obj.matalb_tag_shift_;
            present = labProbe(task_id,matlab_tag);
            if present
                tag_present = mess_tag;
            end
        end
    end
end

