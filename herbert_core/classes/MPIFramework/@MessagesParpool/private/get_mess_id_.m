function [id,tag,is_blocking] = get_mess_id_(tid_requested,message_id,varargin)
% convert any format message id into the format, accepted by standard mpi
% command
%


id = [];
tag = [];
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

if nargin>2
    [ok,mess,synch,asynch]=parse_char_options(varargin,{'-synchronous','-asynchronous'});
    if ~ok
        error('MESSAGES_FRAMEWORK:invalid_argument',mess);
    end
    if synch && asynch
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'Both -synchronous and -asynchronous options are provided as input. Only one is allowed');
    end
    if synch
        is_blocking = true;
    elseif asynch
        is_blocking = false;
    else
        is_blocking = MESS_NAMES.is_blocking(mess_name);
    end
else
    if nargin>1
        is_blocking = MESS_NAMES.is_blocking(tag);
    else
        is_blocking  = false;
    end
end


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
