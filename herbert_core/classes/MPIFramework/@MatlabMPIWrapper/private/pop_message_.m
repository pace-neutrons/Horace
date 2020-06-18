function [message,tag_rec] = pop_message_(obj,target_id,mess_tag,is_blocking)
% Restore requested message from the message cache, if it is
% there, or throw error, if the message is not available
%
% Inputs:
% target_id -- the fake labNum to check for message
% mess_tag  -- if not empty, the message tag to check message
%              for. Empty if any tag is suitable
% is_blocking -- what kind of message is requested. If blocking, throw on
%                missing message, if non-blocking, return empty message on
%                failure.
% Returns:
% message -- the instance of aMessage class, presumablu
%            returned from the target
% tag_rec -- the tag of the received message (duplicates the
%            message class information but provided for
%            convenience.

if isKey(obj.messages_cache_,target_id)
    cont = obj.messages_cache_(target_id);
    info = cont{1};
    tag_rec = info.tag;
    message = info.mess;
    message = aMessage.loadobj(message);
    if ~isempty(mess_tag)
        tag = mess_tag;
        if tag ~=-1
            if tag ~=tag_rec
                if is_blocking
                    error('MESSAGES_FRAMEWORK:runtime_error',...
                        'Attempt to issue blocking receive from lab %d, tag %d Tag present: %d',...
                        target_id,tag,tag_rec )
                else
                    message = [];
                    return;
                end
            end
        end
    end
    if numel(cont)>1
        cont = cont(2:end);
        obj.messages_cache_(target_id) = cont;
    else
        remove(obj.messages_cache_,target_id);
    end
else
    if is_blocking
        error('MESSAGES_FRAMEWORK:runtime_error',...
            'Attempt to issue blocking receive from lab %d',...
            target_id)
    else
        message = [];
        tag_rec = mess_tag;
    end
end
