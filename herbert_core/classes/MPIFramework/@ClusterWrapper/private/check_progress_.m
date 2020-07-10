function [completed,obj] = check_progress_(obj,varargin)
% Check the task progress verifying and receiving all messages, sent from
% worker N1
%
completed = false;
if nargin > 1
    obj.status = varargin{1};
    mess = obj.status;
    tag = mess.tag;
    completed = check_completed(tag);
else
    me = obj.mess_exchange_;
    % check all messages send from the head node.
    [mess_names,tid_from] =me.probe_all('all');
    if isempty(mess_names)
        obj.status_changed_ = false;
    else
        for i=1:numel(mess_names)
            [ok,err,mess] = me.receive_message(tid_from(i),mess_names{i},'-synch');
            if ok ~= MESS_CODES.ok
                error('CLUSTER_WRAPPER:runtime_error',...
                    'Error %s receiving existing message: %s from job %s',...
                    err,mess_names{i},obj.job_id);
            end
            if tid_from(i) ~=1
                if isa(mess,'FailedMessage')
                    disp(mess.fail_text);
                    if ~isempty(mess.exception)
                        mess.exception.getReport()
                    end
                else
                    disp(mess);
                end
            else
                tag = mess.tag;
                completed = check_completed(tag);
                obj.status = mess;
                if completed
                    me.clear_messages();
                    break;
                end
            end
        end
    end
    
end
%
function completed = check_completed(tag)
persistent fin_id;
if isempty(fin_id)
    fin_id = MESS_NAMES.mess_id({'failed','canceled','completed'});
end
if any(tag==fin_id)
    completed = true;
else
    completed = false;
end

