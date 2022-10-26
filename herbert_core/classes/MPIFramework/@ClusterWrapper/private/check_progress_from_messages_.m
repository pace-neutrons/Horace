function [completed,failed,mess] = check_progress_from_messages_(obj,varargin)
% Check the task progress verifying and receiving all messages, sent from
% the cluster.
%
% Normally messages are received from Node 1 only, but if failure occurs,
% additional information may be transmitted from other nodes of the
% cluster.
%
completed = false;
failed    = false;
if nargin == 1
    mess = get_messages_from_framework(obj);
    if isempty(mess)
        return;
    end
else
    mess = varargin{1};
end
tag        = mess.tag;
completed  = check_completed(tag);
failed     = check_failed(tag);

end

function mess = get_messages_from_framework(obj)
me = obj.mess_exchange_;
% check all messages send from all nodes
[mess_names,tid_from] = me.probe_all('all');
if isempty(mess_names)
    mess = ''; %obj.status_changed_ = false;
    return;
else
    mess_arr = cell(1,numel(mess_names));
    tid_from_1_received = 0;
    for i=1:numel(mess_names)
        [ok,err,messl] = me.receive_message(tid_from(i),mess_names{i},'-synch');

        if ok ~= MESS_CODES.ok
            error('HERBERT:ClusterWrapper:runtime_error',...
                'Error %s receiving existing message: %s from job %s',...
                err,mess_names{i},obj.job_id);
        end

        mess_arr{i} = messl;

        if tid_from(i) ~=1 % display messages received from other nodes.
            % it's probably status messages, indicating different
            % problems.
            disp('*****************************************************************');
            fprintf('***** Task: %s initialization/completion error.\n',me.job_id);
            disp('*****************************************************************');

            if isa(messl,'FailedMessage') || isa(messl,'CancelledMessage')
                disp(messl.fail_text);
                if ~isempty(messl.exception)
                    messl.exception.getReport()
                end
                % clear interrupt not to return this diagnostics all
                % the time
                me.clear_interrupt(tid_from(i));
            else
                disp(messl);
            end
        else
            tid_from_1_received=i;
        end
    end

    if tid_from_1_received>0 % we already got message from node 1.
        % It should contain all necessary information abut issues if any
        mess = mess_arr{tid_from_1_received};
    else  % something wrong. The nodes have not transmitted info to headnode but reported directly to user
        % form the failed message
        mess = FailedMessage('No status messages from Node 1, but other nodes sent reports directly to user node');

        all_pl = cell(1,numel(mess_arr)+1);
        all_pl{1} = mess.payload;
        for i=1:numel(mess_arr)
            all_pl{i+1} = mess_arr{i}.payload;
        end
        mess.payload = all_pl;
    end
end

end

function failed = check_failed(tag)
persistent fin_id;
if isempty(fin_id)
    fin_id = MESS_NAMES.mess_id({'failed','cancelled'});
end
failed = any(tag==fin_id)

end

function completed = check_completed(tag)
persistent fin_id;
if isempty(fin_id)
    fin_id = MESS_NAMES.mess_id({'failed','cancelled','completed'});
end
completed = any(tag==fin_id)

end