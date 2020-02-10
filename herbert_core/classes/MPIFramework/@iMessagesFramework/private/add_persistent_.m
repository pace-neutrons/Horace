function [all_messages,mid_from] = add_persistent_(obj,all_messages,mid_from,mes_addr_to_check)
% Helper method used to add persistent messages to the list
% of the messages, received from other labs.
%
% If both messages are received from the same worker, overide
% other message with the persistent message.

% Inputs:
% all_messages -- cellarray of messages to mix with persistent
%                 messages.
% mid_from     -- array of the workers id-s (labNums) where
%                 these messages can be receved.
% mes_addr_to_check -- array of labNums to check for presence
%                 of persistent messages
% Return:
% all_messages  -- cellarray of the all present message names,
%                  persistent and not
% mid_from      -- array of labNum-s sending these messages.
%
if isempty(mes_addr_to_check)
    mes_addr_to_check = int32(1:obj.numLabs);
end

% check if any persistent messages exist for checked labs
[pers_mess,pers_sources] = obj.check_get_persistent(mes_addr_to_check);
% if they are, mix persistent message names with the names, received from
% the framework
if ~isempty(pers_mess)
    pmess_names = cellfun(@(x)(x.mess_name),pers_mess,'UniformOutput',false);
    coinside = ismember(int32(mid_from),pers_sources);
    if any(coinside)
        double_id = mid_from(coinside);
        in_pesistent = ismember(pers_sources,double_id);
        all_messages(coinside) = pmess_names(in_pesistent);
        pers_soruces_rem = pers_sources(~in_pesistent);
        pers_name_rem = pmess_names(~in_pesistent);
        all_messages = [all_messages(:);pers_name_rem(:)];
        mid_from     = [mid_from(:);pers_soruces_rem(:)];
    else
        all_messages = [all_messages(:);pmess_names(:)];        
        mid_from     = [mid_from(:);pers_sources(:)];        
    end
    all_messages = reshape(all_messages,1,numel(all_messages));
    mid_from  = reshape(mid_from,1,numel(all_messages));
    [mid_from,id] = sort(mid_from);
    all_messages  = all_messages(id);
end
