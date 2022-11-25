function obj = set_efix(obj,efix,emode)
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
if ~(isnumeric(efix) && numel(efix)>=1 && all(isfinite(efix)) && all(efix>=0))
    error('HORACE:sqw:invalid_argument',...
        'efix must be numeric scalar or array of finite values');
end
if ~exist('emode','var')
    emode=[];   % indicates emode to be left untouched
else
    if ~(isnumeric(emode) && isscalar(emode) && (emode==0||emode==1||emode==2))
        error('HORACE:sqw:invalid_argument',...
            'emode must 1 (direct geometry), 2 (indirect geometry) or 0 (elastic)')
    end
end


% Change efix and emode
% ---------------------

% Check the number of spe files matches the number of efix
% check what kind of efix array is provided and beeing set.
% single for all objects, change each object or change all
% objects
nefix=numel(efix);
n_runs_in_obj = arrayfun(@(x)x.experiment_info.n_runs,obj);
eq_nefix = n_runs_in_obj == nefix;
split_emode = false;
if all(eq_nefix)
    split_runs = false;
elseif nefix == sum(n_runs_in_obj) && nefix ~=1
    split_runs = true;
    if ~isempty(emode)
        if numel(emode) ~= nefix
            error('HORACE:sqw:invalid_argument',...
                'Array of efix and emodes are provided, but the length of efix array (%d) is different from the length of emode array (%d)',...
                nefix,numel(emode))
        end
        split_emode = true;
    else % numel(emode) == 1;
        split_emode = false;
    end
elseif nefix == 1
    split_runs = false;
else
    error('HORACE:sqw:invalid_argument',...
        ['An array of efix values was given but its length (%d) ',...
        'does not match the number of runs either in every object (%d) or in all sqw objects together (%d)'],...
        nefix,n_runs_in_obj(1),sum(n_runs_in_obj));
end

% Change efix and emode for each data source in a loop
n_runs_set = 0;
for i=1:numel(obj)
    % Change the header
    exp_inf  = obj(i).experiment_info;
    if split_runs
        if split_emode
            exp_inf = set_efix_emode(exp_inf, ...
                efix(n_runs_set+1:n_runs_set+n_runs_in_obj(i)), ...
                emode(n_runs_set+1:n_runs_set+n_runs_in_obj(i)));
        else
            exp_inf = set_efix_emode(exp_inf, ...
                efix(n_runs_set+1:n_runs_set+n_runs_in_obj(i)), ...
                emode);
        end
        n_runs_set = n_runs_set+n_runs_in_obj(i);        
    else
        exp_inf = set_efix_emode(exp_inf,efix,emode);
    end
    obj(i).experiment_info = exp_inf;
end

function exp_inf = set_efix_emode(exp_inf,efix,emode)
if isempty(emode)
    exp_inf   = exp_inf.set_efix_emode(efix,'-keep_emode');   %
else
    exp_inf   = exp_inf.set_efix_emode(efix,emode);
end
