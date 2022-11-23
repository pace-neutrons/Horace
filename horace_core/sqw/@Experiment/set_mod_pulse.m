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
if inst.n_unique == size(pm_par,1)
    unique_inst = inst.unique_objects;
    for i=1:numel(unique_inst)
        unique_inst{i} = unique_inst.set_mod_pulse(pulse_model,pm_par(i,:));
    end
    inst.unique_objects = unique_inst;    
elseif inst.n_runs == size(pm_par,1)
    for i=1:inst.n_runs
        inst_mod = inst(i);
        inst(i)  = inst_mod.set_mod_pulse(pulse_model,pm_par(i,:));
    end
else
    error('HORACE:Experiment:invalid_argument', ...
        ['The number of moderator pulse parameters=%d.\n', ...
        ' It is equal neither to the number of unique instruments: (%d)\n', ...
        ' nor to the total number of contributed runs: %d'],...
        size(pm_par,1),inst.n_unique,inst.n_runs);
end
obj.instruments = inst;
