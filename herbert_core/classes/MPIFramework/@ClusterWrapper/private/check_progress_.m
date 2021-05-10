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
            if tid_from(i) ~=1 % display messages received from other nodes.
                % its probably status messages, indicating different
                % problems.
                disp('*****************************************************************');
                fprintf('***** Task: %s initialization/completeon error.\n',me.job_id);
                disp('*****************************************************************');
                
                if isa(mess,'FailedMessage') || isa(mess,'CancelledMessage')
                    disp(mess.fail_text);
                    if ~isempty(mess.exception)
                        mess.exception.getReport()
                    end
                    % clear interrupt not to return this diagnostics all
                    % the time
                    me.clear_interrupt(tid_from(i));
                else
                    disp(mess);
                end
            else % only messages from node 1 are proper information messages
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
    fin_id = MESS_NAMES.mess_id({'failed','cancelled','completed'});
end
if any(tag==fin_id)
    completed = true;
else
    completed = false;
end

