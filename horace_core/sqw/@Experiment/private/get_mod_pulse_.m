function [pulsemodel,pm_par,present] = get_mod_pulse_(obj)
%GET_MOD_PULSE_  % Get moderator pulse model names and array of pulse parameters
% from all runs, contributing to the class.
%
% If pulsemodel is the same for all runs, pulsemodel is returned as a string.
% if pulsemodel is different, it returned as cellarray
%
% Ouptuts:
% pulsemodel -- the name of the pulse model used for moderator
% pm_par     --
%
inst = obj.instruments_;
n_runs  = inst.n_runs;
pulsemodel = '';
pm_par = [];
present = true;

uni_inst = inst.unique_objects;
try
    first_model = uni_inst{1}.moderator.pulse_model;
catch ME
    if strcmp(ME.identifier,'HORACE:IX_inst:runtime_error')
        present = false;
        return;
    else
        rethrow(ME)
    end
end
try
    is_same = cellfun(@(x)strcmp(x.moderator.pulse_model,first_model),uni_inst);
catch ME
    if strcmp(ME.identifier,'HORACE:IX_inst:runtime_error')
        present = false;
        return;
    else
        rethrow(ME)
    end
end
if all(is_same)
    pulsemodel = first_model;
else
    pulsemodel = cell(1,n_runs);
    for i=1:n_runs
        inst_i = inst(i); % container does not allow subsequent subscripts
        pulsemodel{i} = inst_i.moderator.pulse_model;
    end
end
pp_arr = cell(1,n_runs);
for i=1:n_runs
    inst_i = inst(i);  % container does not allow subsequent subscripts
    pp_arr{i} = inst_i.moderator.pp';
end
if ~iscell(pulsemodel)
    pm_par = [pp_arr{:}]';
end