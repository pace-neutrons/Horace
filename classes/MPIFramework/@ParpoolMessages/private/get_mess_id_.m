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
    if isa(varargin{2},'char')
        tag = MESS_NAMES.mess_id(varargin{2});
    elseif isa(varargin{2},MESS_NAMES)
        tag  = int(varargin{2});
    else
        tag = varargin{2};
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
