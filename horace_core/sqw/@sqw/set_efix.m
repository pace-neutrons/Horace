function obj = set_efix(obj,varargin)
% Set the fixed neutron energy for an array of sqw objects.
%
%   >> wout = set_efix(win, efix)
%   >> wout = set_efix(win, efix, emode)
%
% Input:
% ------
%   obj         Array of sqw objects of sqw type
%   efix        Value or array of values of efix. If an array, all sqw
%              objects must have the same number of contributing spe data sets
%   emode       [Optional] Energy mode: 1=direct inelastic, 2=indirect inelastic, 0=elastic
%
% Output:
% -------
%   wout        Output sqw objects


% Original author: T.G.Perring
%



% Perform operations
% ==================
narg=numel(varargin);
if narg<1 || narg>2
    error('HORACE:sqw:invalid_argument',...
        'This function accepts one or two input arguments')
end
if narg>=1
    efix=varargin{1}(:);
    if ~(isnumeric(efix) && numel(efix)>=1 && all(isfinite(efix)) && all(efix>=0))
        error('HORACE:sqw:invalid_argument',...
            'efix must be numeric scalar or array of finite values');
    end
end
if narg>=2
    emode=varargin{2};
    if ~(isnumeric(emode) && isscalar(emode) && (emode==0||emode==1||emode==2))
        error('HORACE:sqw:invalid_argument',...
            'emode must 1 (direct geometry), 2 (indirect geometry) or 0 (elastic)')
    end
else
    emode=[];   % indicates emode to be left untouched
end


% Change efix and emode
% ---------------------

% Check the number of spe files matches the number of efix
nefix=numel(efix);
if nefix>1
    for i=1:numel(obj)
        if obj(i).experiment_info.n_runs ~=nefix
            error('HORACE:sqw:invalid_argument',...
                ['An array of efix values was given but its length (%d) ',...
                'does not match the number of spe files (%d) in the sqw N:%d source being altered'],...
                nefix,obj(i).experiment_info.n_runs,i)
        end
    end
end

% Change efix and emode for each data source in a loop
for i=1:numel(obj)
    % Change the header
    exp_inf  = obj(i).experiment_info;
    if isempty(emode)
        exp_inf   = exp_inf.set_efix_emode(efix,'-keep_emode');   %
    else
        exp_inf   = exp_inf.set_efix_emode(efix,emode);
    end
    obj(i).experiment_info = exp_inf;
end