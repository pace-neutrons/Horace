function [completed,obj] = check_progress_(obj,varargin)
% Check the task progress verifying and receiving all messages, sent from
% worker N1
%
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)
%
completed = false;
if nargin > 1
    obj.status = varargin{1};
    mess = obj.status;
    tag = mess.tag;
    completed = check_completed(tag);
else
    me = obj.mess_exchange_;
    mess_names =me.probe_all(1);
    if isempty(mess_names)
        obj.status_changed_ = false;
    else
        for i=1:numel(mess_names)
            [ok,err,mess] = me.receive_message(1,mess_names{i});
            if ok ~= MESS_CODES.ok
                error('CLUSTER_WRAPPER:runtime_error',...
                    'Error %s receiving existing message: %s from job %s',...
                    err,mess_names,obj.mess_exchange_.job_id);
            end
            tag = mess.tag;
            completed = check_completed(tag);
            obj.status = mess;
        end
    end
end
%
function completed = check_completed(tag)
persistent fin_id;
if isempty(fin_id)
    fin_id = MESS_NAMES.mess_id('failed','canceled','completed');
end
if any(tag==fin_id)
    completed = true;
else
    completed = false;
end
