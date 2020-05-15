function [message,tag,source]=labReceive_(obj,targ_id,mess_tag)
% wrapper around Matlab labReceive operation.
% Inputs:
% targ_id  - the number of the lab to ask the information from
% mess_tag - the tag of the information to ask for. if it is
%            empty, any type of information is requested.
% Returns:
% message   -- the instance of aMessage class, containing the
%              requested information
%
% in production mode: Blocks until correspondent message has
%               been sent
if obj.is_tested
    [message,tag,source] = pop_message_(obj,targ_id,mess_tag);
else
    if isempty(targ_id)
        [message,source,tag] = labReceive;
    elseif mess_tag == -1
        source = targ_id;
        message = labReceive(targ_id);
    else % nargin == 3 or more
        source = targ_id;
        tag     = mess_tag;
        message = labReceive(targ_id,mess_tag);
    end
end

