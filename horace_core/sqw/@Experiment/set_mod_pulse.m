function obj = set_mod_pulse(obj,pulse_model,pm_par)
% Set moderator pulse model on all unique instruments, contributed in the
% experiment
% Input:
% ------
%   obj         Experiment object
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pp          Pulse shape parameters: row vector for a single set of parameters
%               or a 2D array, one row per spe data set for each instrument 
%               of the sqw object(s).
%
% Output:
% -------
%   obj         Modified experiment

%

inst = obj.instruments;
% case where a single parameter row is provided for instruments in all runs
if 1 == size(pm_par,1)
    for i=1:inst.n_runs
        inst_mod = inst(i);
        inst(i)  = inst_mod.set_mod_pulse(pulse_model,pm_par(1,:));
    end
% case where a separate parameter row is provided for the instrument in
% each run
elseif inst.n_runs == size(pm_par,1)
    for i=1:inst.n_runs
        inst_mod = inst(i);
        inst(i)  = inst_mod.set_mod_pulse(pulse_model,pm_par(i,:));
    end
else
    error('HORACE:Experiment:invalid_argument', ...
        ['The number of moderator pulse parameters=%d.\n', ...
        ' It is equal neither to one (shared with all runs)\n', ...
        ' nor to the total number of contributed runs: %d'],...
        size(pm_par,1),inst.n_runs);
end
obj.instruments = inst;
