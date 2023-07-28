function obj = init_(obj,varargin)
% INIT_ construcnt non-empty instance of this class
% Usage:
%   obj = init(obj,filename, filepath, efix,emode,cu,cv,psi,...
%               omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,...
%               ulabel,run_id)

% the list of the fieldnames, which may appear in constructor
% in the order they may appear in the constructor.
flds = {'filename', 'filepath', 'efix','emode','cu',...
    'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
    'u_to_rlu','ulen','ulabel','run_id'};

if nargin == 2
    input = varargin{1};
    if isa(input,'IX_experiment')
        obj = input ;
        return
    elseif isstruct(input)
        % constructor
        % The constructor parameters names in the order, then can
        % appear in constructor
        obj = IX_experiment.loadobj(input);
    else
        error('HERBERT:IX_experiment:invalid_argument',...
            'Unrecognised single input argument of class %s',...
            class(input));
    end
elseif nargin > 2
    % list of crude validators, checking the type of all input
    % parameters for constructor. Mainly used to identify the
    % end of positional arguments and the beginning of the
    % key-value pairs. The accurate validation should occur on
    % setters.
    [obj,remains] = set_positional_and_key_val_arguments(obj,...
        flds,false,varargin{:});
    if ~isempty(remains)
        error('HERBERT:IX_experiment:invalid_argument',...
            'Non-recognized extra-arguments provided as input for constructor for IX_experiemt: %s', ...
            disp2str(remains));
    end
else
    error('HERBERT:IX_experiment:invalid_argument',...
        'unrecognised number of input arguments: %d',nargin);
end
if isempty(obj)
    error('HERBERT:IX_experiment:invalid_argument',...
        'initialized IX_experiment can not be empty')
end
