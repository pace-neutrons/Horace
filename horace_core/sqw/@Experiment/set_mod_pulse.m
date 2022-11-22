function obj = set_mod_pulse(obj,pulse_model,pm_par)
% Set moderator pulse model on all unique instruments, contributed in the
% experiment
% Input:
% ------
%   obj         Experiment object
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pp          Pulse shape parameters: row vector for a single set of parameters
%               or a 2D array, one row per spe data set in the sqw object(s).
%
% Output:
% -------
%   obj         Modified experiment

%
inst = obj.instruments;
uniq_inst = inst.unique_objects;
for i=1:numel(uniq_inst)
    uniq_inst{i} = uniq_inst.set_mod_pulse(pulse_model,pm_par);        
end
inst.unique_objects = uniq_inst;
obj.instruments = inst;
