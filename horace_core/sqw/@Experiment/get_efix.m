function efix = get_efix(obj)
% Return array of incident energies from all runs, contributing to
% experiment.

% the arrayfun form is necessary for indirect instruments, which would bave
% multiple efix and the efix may change from run to run. 
efix = arrayfun(@(x)x.efix(:)',obj.expdata_,'UniformOutput',false);
efix = [efix{:}];
