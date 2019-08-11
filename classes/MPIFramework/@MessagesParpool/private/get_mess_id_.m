function [id,tag,labReceiveSimulator] = get_mess_id_(tid_requested,message_id)
% convert any format message id into the format, accepted by standard mpi
%
id = [];
tag = [];
labReceiveSimulator = [];
if nargin == 0
    return;
end
id = check_id(tid_requested);
if exist('message_id','var')
    if isempty(message_id)
        return;
    end
    
    if ischar(message_id)
        tag = MESS_NAMES.mess_id(message_id);
    elseif isnumeric(message_id)
        tag  = check_tag(message_id);
    else
        error('PARPOOL_MESSAGES:invalid_argument',...
            'unrecognized message labIndex should be numeric')
    end
end
% if nargin == 3
%     labReceiveSimulator = varargin{1};
% else
%
% end

function id = check_id(input)
if ~isnumeric(input)
    error('PARPOOL_MESSAGES:invalid_argument',...
        'labIndex should be numeric. It is: %s',class(input))
end
id = double(input);

function tag = check_tag(input)
if MESS_NAMES.tag_valid(input)
    tag = double(input);
else
    error('PARPOOL_MESSAGES:invalid_argument',...
        'unrecognized numeric message tag %d',input)
end
