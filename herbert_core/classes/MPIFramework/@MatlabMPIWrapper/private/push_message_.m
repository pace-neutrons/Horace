function push_message_(obj,message,target_id,mess_tag)
% store message intended for the lab specified in the message
% cache.
% Input:
% message -- instance of aMessage class to send
% target_id - the number of lab to send message to.
% mess_tag -- the tag indicating the message type.
%             (duplicate of the tag field of the message,
%             provided for interface completenes)
if isKey(obj.messages_cache_,target_id)
    cont = obj.messages_cache_(target_id);
    interrupts = MESS_NAMES.instance().interrupt_tags;
    if any(ismember(mess_tag,interrupts)) % this is not how real MPI may or may not work
        % the question is if only first send message tag is present when you
        % issued labProbe for the next tag. But to ensure equivalence with
        % filebased messages, where all send messages are available, let's
        % do this
        cont = [{struct('tag',mess_tag,'mess',message.saveobj())},cont{:}];
    else
        cont{end+1} = struct('tag',mess_tag,'mess',message.saveobj());
    end
    obj.messages_cache_(target_id) = cont;
else
    obj.messages_cache_(target_id) = {struct('tag',mess_tag,'mess',message.saveobj())};
end

end
