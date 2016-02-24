function   [all_messages,job_ids] = receive_all_messages_(obj,job_ids)
% retrieve all messages intender for jobs with id provided
%
message_names = list_all_messages_(obj,job_ids);

existing = cellfun(@(x)(~isempty(x)),message_names);
message_names = message_names(existing);
job_ids       = job_ids(existing);
all_messages = cell(numel(job_ids),1);

for i=1:numel(job_ids)
    [ok,err_mess,message]=receive_message_(obj,job_ids(i),message_names{i});
    if ~ok
        warning('MESSAGES_FRAMEWORK:invalid_message',...
            'Can not retrieve message: %s, reported to framework as existing, Err: %s',...
            message_names{i},err_mess);
        message=[];
    end
    all_messages{i} = message;
end
