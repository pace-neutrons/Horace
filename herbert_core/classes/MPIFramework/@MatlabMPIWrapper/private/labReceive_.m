function [message,tag,source]=labReceive_(obj,targ_id,mess_tag,is_blocking)
% wrapper around Matlab labReceive operation.
% Inputs:
% targ_id  - the number of the lab to ask the information from
% mess_tag - the tag of the information to ask for. if it is
%            empty, any type of information is requested.
% source  -- the address of the node, the result has been returned from.
%            current version -- must be equal to taget_id
%
% Returns:
% message   -- the instance of aMessage class, containing the
%              requested information
%
% in production mode: Blocks until correspondent message has
%               been sent
if obj.is_tested
    [message,tag,source] = pop_message_(obj,targ_id,mess_tag,is_blocking);
else
    if isempty(targ_id)
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'Requesting receive from undefined lab')
        %[message,source,tag] = labReceive;
    elseif mess_tag == -1
        source = targ_id;
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
        source = targ_id;
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

