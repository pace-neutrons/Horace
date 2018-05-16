function [id,tag,labReceiveSimulator] = get_mess_id_(varargin)
% convert any format message id into the format, accepted by standard mpi
%
id = [];
tag = [];
labReceiveSimulator = [];
if nargin == 0
    return;
elseif nargin == 1
    id = check_id(varargin{1});
elseif nargin >= 2
    id = check_id(varargin{1});
    if ischar(varargin{2})
        if ~isempty(varargin{2})
            tag = MESS_NAMES.mess_id(varargin{2});
        end
    elseif isnumeric(varargin{2})
        tag  = check_tag(varargin{2});
    else
        error('PARPOOL_MESSAGES:invalid_argument',...
            'unrecognized message labIndex should be numeric')
    end
end
% if nargin == 3
%     labReceiveSimulator = varargin{3};
% else
%
% end

function id = check_id(input)
if ~isnumeric(input)
    error('PARPOOL_MESSAGES:invalid_argument',...
        'labIndex should be numeric')
end
id = double(input);

function tag = check_tag(input)
if MESS_NAMES.tag_valid(input)
    tag = double(input);
else
    error('PARPOOL_MESSAGES:invalid_argument',...
        'unrecognized numeric message tag %d',input)
end
