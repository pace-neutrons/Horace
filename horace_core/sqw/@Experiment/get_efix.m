function efix = get_efix(obj)
% Return array of incident energies from all runs, contributing to
% experiment
efix = arrayfun(@(x)x.efix(:)',obj.expdata_,'UniformOutput',false);
efix = [efix{:}];
