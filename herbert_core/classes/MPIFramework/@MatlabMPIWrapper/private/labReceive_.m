function [message,tag]=labReceive_(obj,targ_id,mess_tag,is_blocking)
% wrapper around Matlab labReceive operation with possibility to enable
% test mode when the messages are extracted from the test-messages cache.
%
% Inputs:
% targ_id  - the number of the lab to ask the information from
% mess_tag - the tag of the information to ask for. if it is
%            empty, any type of information is requested.
% is_blocking - if true, operation waits until correspondent message have been send.
%              if false, returns empty message if appropriate message has
%              not yet been send.
%
% Returns:
% message   -- the instance of aMessage class, containing the
%              requested information
% tag       -- convenience value containing the tag of the received
%              message.
if isempty(targ_id) || (isnumeric(targ_id) && targ_id == -1)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Requesting receive from undefined lab')
end

if obj.is_tested
    [message,tag] = pop_message_(obj,targ_id,mess_tag,is_blocking);
else
    if mess_tag == -1
        if is_blocking
            message = labReceive(targ_id);
            tag = message.tag;
        else
            isDataAvail = labProbe(targ_id);
            if isDataAvail
                message = labReceive(targ_id);
                tag = message.tag;
                
            else
                message = [];
                tag = [];
            end
        end
    else % nargin == 3 or more
        mess_tag     = mess_tag+obj.matalb_tag_shift_;
        if is_blocking
            message = labReceive(targ_id,mess_tag);
            tag = message.tag;
        else
            isDataAvail = labProbe(targ_id,mess_tag);
            if isDataAvail
                message = labReceive(targ_id,mess_tag);
                tag = message.tag;
            else
                message = [];
                tag = [];
            end
        end
    end
end

