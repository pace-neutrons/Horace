function [ok,err_mess,message] = receive_message_(obj,varargin)
ok = true;
err_mess = [];
[id,tag,labReceiveSimulator] = get_mess_id_(varargin{:});
% disabled due to the bug in the parallel parser
% if ~isempty(labReceiveSimulator)
%     labReceive = labReceiveSimulator();
% end
try
    if isempty(id)
        message = labReceive();
    elseif isempty(tag)
        %fprintf('lab: %d ! id = %d\n',obj.labIndex,id);
        message = labReceive(id);
    else % nargin == 3 or more
        message = labReceive(id,tag);
    end
catch Err
    ok = false;
    err_mess = Err;
    message = [];
end


