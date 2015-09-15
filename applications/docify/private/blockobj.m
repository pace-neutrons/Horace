function a=blockobj(S,opt,varargin)
% Store nest of block names and storing status
%
%   >> S = blockobj
%   >> S = blockobj(S, 'add', nam2, log2)
%   >> S = blockobj(S, 'remove')
%   >> name = blockobj(S, 'current')
%   >> status = blockobj(S, 'storing')

S_empty=struct([]);

% Case of initialisation
if nargin==0
    a=S_empty;  % initialised
    return
end

% Check storage structure has right format
if isempty(S) || (isstruct(S) && isempty(fieldnames(S(1))))
    S=S_empty;   % standard 'no blocks'
elseif ~(isstruct(S) && all(strcmp(fieldnames(S(1)),{'name';'storing'})))
    error('Block storage argument does not have correct form')
end

% Perform operations
if strcmpi(opt,'current')
    if ~isempty(S)
        a=S(end).name;
    else
        error('No blocks stored')
    end
    
elseif strcmpi(opt,'storing')
    if ~isempty(S)
        a=S(end).storing;
    else
        error('No blocks stored')
    end
    
elseif strcmpi(opt,'add')
    if numel(varargin)==2 && is_string(varargin{1}) &&...
            ~isempty(varargin{1}) && islognumscalar(varargin{2})
        a=[S,struct('name',varargin{1},'storing',logical(varargin{2}))];
    else
        error('Invalid input for adding a block to the store')
    end
    
elseif strcmpi(opt,'remove')
    if ~isempty(S)
        if numel(S)>1
            a=S(1:end-1);
        else
            a=S_empty;
        end
    else
        error('No blocks stored')
    end
    
else
    error('Unrecognised operation')
    
end
