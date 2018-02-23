function obj = check_and_set_parpool_framework_(obj)
% verify if one can set and use parallel framework based on Matlab parallel
% computing toolbox

ok = license('checkout','Distrib_Computing_Toolbox');
if ~ok
    error('PARALLEL_CONFIG:runtime_error',...
        ' Parallel computer toolbox is not availible. Can not use parpool parallelization')
end
if verLessThan('matlab','8.4')
    error('PARALLEL_CONFIG:runtime_error',...
        'Matlab parpool options become availible from Matlab v2013b')
end
config_store.instance().store_config(...
    obj,'parallel_framework','parpool');

