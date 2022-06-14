function [messages,tid_from] = mix_messages_(messages,tid_from,add_mess,tid_add_from)
% helper function to add more messages to the list of existing messages
%
% Used to add interrupts to list of existing messages.
% the additional messages overwrite the old one if have the same task id-s
% Inputs:
% messages -- cellarray of objects
% tid_from -- numeric array of indexes, indicating where the
%             objects are obtained from.
%             Requested size(messages) == size(tid_from);
% add_mess -- cellarray of additional objects
% tid_add_from -- array of indexes, inticating where additional
%                 objects have arrived from. The values may
%                 coinside withsome or all indexes from
%                 tid_from.
%             Requested size(add_mess) == size(tid_add_from);
% Returns
% messages  -- cellarray of objects, combined from messages and
%              add_mess celarrays
% tid_from  -- unique indexes, sources of objects in messaves
%              celarray
% if some indexes in tid_from coinside with indexes from
% tid_add_from, the values in correspondent cells of outipt messages
% are replaced by correspondent values from  add_mess;
%
if isempty(add_mess)
    return;
end
if isempty(messages)
    messages = add_mess;
    tid_from = tid_add_from;
end
if any(numel(messages)~= numel(tid_from))
    error('iMESSAGES_FRAMEWOR:invalid_argument',...
        'size of messages array needs to be equal to size of source indexes')
end
if any(numel(add_mess)~= numel(tid_add_from))
    error('iMESSAGES_FRAMEWOR:invalid_argument',...
        'size of additional messages array needs to be equal to size of additional source indexes')
end


range = double(max(max(tid_from),max(tid_add_from)));

% convert to cellarray of empty or full messages
mess_cell     = cell(1,numel(range));
from_all_labs = false(1, range); % boolean indicating empty messages from anywhere

mess_cell(tid_from)= messages(:);
from_all_labs(tid_from) = true;
mess_cell(tid_add_from) = add_mess(:);
from_all_labs(tid_add_from) = true;

whole_range = 1:range;
tid_from = whole_range(from_all_labs);
messages = mess_cell(from_all_labs);

end
