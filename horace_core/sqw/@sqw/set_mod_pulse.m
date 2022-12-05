function obj = set_mod_pulse(obj,pulse_model,pm_par)
% Set the moderator pulse shape model and pulse parameters for an array of sqw objects.
%
%   >> obj = set_mod_pulse(obj, pulse_model, pp)
%
% Input:
% ------
%   obj         Array of sqw objects of sqw type
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pm_par      Pulse shape parameters: row vector for a single set of parameters
%               or a 2D array, one row per spe data set in the sqw object(s).
%
% Output:
% -------
%   obj        Output sqw objects


% Original author: T.G.Perring
%

% check what kind of pulse parameters is provided and beeing set. 
% single for all models, change unique instruments or change all
% instruments
if size(pm_par,1) == 1
    set_single_par = true;
else
    set_single_par = false;
    n_tot_runs = arrayfun(@(x)x.experiment_info.n_runs,obj);
    n_unique_runs = arrayfun(@(x)x.experiment_info.instruments.n_unique,obj);
    n_tot_runs = sum(n_tot_runs);
    n_unique_runs = sum(n_unique_runs);
    num_params = size(pm_par,1);
    if num_params == n_tot_runs  % set all parameters, one paramm per contributing object
        set_total = true;
    elseif num_params == n_unique_runs % set unique
        set_total = false;
    else
        error('HORACE:sqw:invalid_argument',...
            'Total number of moderator parameters (%d) not equal to 1 and to either to number of total runs (%d) nor the number of unique runs (%d)',...
            num_params,n_tot_runs,n_unique_runs);
    end
end

n_run_set = 0;
for i=1:numel(obj)
    if set_single_par
        obj(i).experiment_info = obj(i).experiment_info.set_mod_pulse( ...
            pulse_model,pm_par);
    else
        if set_total
            n_runs = obj(i).experiment_info.n_runs;
        else % split unique
            n_runs = obj(i).experiment_info.instruments.n_unique;
        end
        obj(i).experiment_info = obj(i).experiment_info.set_mod_pulse( ...
            pulse_model,pm_par(n_run_set+1:n_run_set+n_runs,:));
        n_run_set = n_run_set + n_runs;

    end
end