function [pulse_model,pm_par,ok,mess,p,present] = get_mod_pulse(obj,tol)
% Get moderator pulse model name and mean pulse parameters for an array of sqw objects
%
%   >> [pulse_model,pp,ok,mess,p,present] = get_mod_pulse (win)
%   >> [pulse_model,pp,ok,mess,p,present] = get_mod_pulse (win,tol)
%
% Input:
% ------
%   obj         Array of sqw objects of sqw type
%   tol         [Optional] acceptable relative spread w.r.t. average of moderator
%              pulse shape parameters: maximum over all parameters of
%                   max(|max(p)-p_ave|,|min(p)-p_ave|) <= tol
%
% Output:
% -------
%   pulse_model Name of moderator pulse shape model e.g. 'ikcarp'
%              Must be the same for all data sets in all sqw objects
%             (Returned as [] if not all the same pulse model or length of
%              pulse parameters array not all the same)
%   pp          Mean moderator pulse shape parameters (numeric row vector)
%             (Returned as [] if not all the same pulse model or length of
%              pulse parameters array not all the same)
%   ok          Logical flag: =true if all parameters within tolerance, otherwise =false;
%   mess        Error message; empty if OK, non-empty otherwise
%   p           Structure with various information about the spread
%                   p.pp       array of all parameter values, one row per data set
%                   p.ave      average parameter values (row vector)
%                             (same as output argument pp)
%                   p.min      minimum parameter values (row vector)
%                   p.max      maximum parameter values (row vector)
%                   p.relerr   larger of (max(p)-p_ave)/p_ave
%                               and abs((min(p)-p_ave))/p_ave
%                 (If pulse model or not all the same, or number of parameters
%                  not the same for all data sets, ave,min,max,relerr all==[])
%   present     True if a moderator is present in all sqw objects; false otherwise


% Original author: T.G.Perring

% Parse input
% -----------
if exist('tol','var') 
    if ~(isnumeric(tol) && isscalar(tol) && tol >=0)
    error('HORACE:sqw:invalid_argument', ...
        'Optional fractional tolerance should be a non-negative scalar. It is: %s',...
        disp2str(tol))
    end
else
    tol=5e-3;   % relative tolerance of spread of pulse shape parameters 
end
present = true;
p = struct();

% Perform operations
% ------------------


% Get values
nobj=numel(obj);     % number of sqw objects or files
pm_list = cell(1,nobj);
pm_par = cell(1,nobj);
for i=1:nobj
    exper=obj(i).experiment_info;
    [pm_list{i},pm_par{i},present] = exper.get_mod_pulse();
    if ~present
        mess = sprintf('Object N%d does not have defined moderator',i);
        ok = false;
        return;
    end
    if iscell(pm_list{i})
        mess = sprintf('Object N%d contains more then one different pulse model',i);        
        ok = false;
        return;        
    end
    pm_par{i} = pm_par{i}';
end
pm_arr = [pm_par{:}]';
[pulse_model,pm_par,ok,mess,p] =Experiment.calc_mod_pulse_avrgs(pm_arr,pm_list,tol);

