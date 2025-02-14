function efix = get_efix(obj)
% Return cellarray of incident energies from all runs, contributing to
% experiment.

% the output cellarray form is necessary for indirect instruments, which
% would have multiple efix. (it is analyzer energy there).  Efix may also
% change from run to run.

efix = arrayfun(@(x)x.efix(:)',obj.expdata_,'UniformOutput',false);

