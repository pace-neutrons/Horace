function [id,tag,is_blocking] = get_mess_id_(obj,tid_requested,message_id,varargin)
% convert any format message id into the format, accepted by standard mpi
% command
%


id = [];
tag = 'any';
if nargin == 0
    return;
end
id = check_id(tid_requested);
if exist('message_id', 'var')
    if isempty(message_id)
        return;
    end
    
    if ischar(message_id)
        tag = MESS_NAMES.mess_id(message_id);
    elseif isnumeric(message_id)
        tag  = check_tag(message_id);
    else
        error('PARPOOL_MESSAGES:invalid_argument',...
            'unrecognized message labIndex should be numeric tag correspondent to message or ')
    end
end
% check if the message should be received synchroneously or asynchroneously
is_blocking = obj.check_is_blocking(tag,varargin);


function id = check_id(input)
if ischar(input) && strcmpi(input,'any')
    input = [];
end
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
