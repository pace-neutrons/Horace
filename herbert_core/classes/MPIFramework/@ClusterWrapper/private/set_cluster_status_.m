function obj = set_cluster_status_(obj,mess)
% private setter for status property
%
% Does substiturions for messages
% running -> log
% finished-> completed
%
if isa(mess,'aMessage')
    stat_mess = mess;
elseif ischar(mess)
    if strcmp(mess,'log') || strcmpi(mess,'running')
        if strcmpi(mess,'running')
            mess = 'log';
        end
        if ~isempty(obj.current_status_) && ...
                strcmp(obj.current_status_.mess_name,'log')
            stat_mess = obj.current_status_;
        else
            stat_mess  = MESS_NAMES.instance().get_mess_class(mess);
        end
    elseif strcmp(mess,'finished')
        stat_mess = CompletedMessage();
    else
        stat_mess = MESS_NAMES.instance().get_mess_class(mess);
    end
else
    error('HERBERT:ClusterParpoolWrapper:invalid_argument',...
        'status is defined by aMessage class only or a message name')
end

obj.prev_status_ = obj.current_status_;
obj.current_status_ = stat_mess;
if obj.prev_status_ ~= obj.current_status_
    obj.status_changed_ = true;
else
    obj.status_changed_ = false;
end


