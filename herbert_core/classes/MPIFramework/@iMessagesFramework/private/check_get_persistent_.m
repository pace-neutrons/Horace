function [mess,id_from] = check_get_persistent_(obj,source_address)
% check if a message is a persistent message (the message
% describing a state of the source which persists until the
% current job is completed or aborted) and return these
% persistent messages.
% Input:
% source_address -- the array of addresses to check for sources
%                   of the persistent messages
% Returns:
% mess   -- cellarray of persisting messages returned from all
%           or some sources requested
%id_from -- array of the addresses which have previously
%           generated persistent messages, stored within the
%           framework

mess = {};
id_from = source_address;
if isempty(obj.persistent_fail_message_)
    return;
end
if isempty(source_address) || (ischar(source_address) && strcmp(source_address,'any'))
    id_from = obj.persistent_fail_message_.keys();
    id_from = [id_from{:}];
    mess = obj.persistent_fail_message_.values();
    return;
end
if numel(source_address) == 1
    if isKey(obj.persistent_fail_message_,int32(source_address))
        mess = obj.persistent_fail_message_(int32(source_address));
    end
else
    all_id = obj.persistent_fail_message_.keys();
    all_id = [all_id{:}];
    present = ismember(all_id,int32(source_address));
    if any(present)
        id_from = all_id(present);
        all_mess = obj.persistent_fail_message_.values();
        mess = all_mess(present);
    end
    
end
