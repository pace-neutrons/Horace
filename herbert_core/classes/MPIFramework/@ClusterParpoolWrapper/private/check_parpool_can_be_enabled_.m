function check_parpool_can_be_enabled_(obj)
% verify if one can set and use parallel framework based on Matlab parallel
% computing toolbox

err_mess = [];
ok = license('checkout','Distrib_Computing_Toolbox');
if ~ok
    err_mess = 'License for parallel computer toolbox is not available. Can not use parpool parallelization';
end
if verLessThan('matlab','8.4')
    err_mess =  'Matlab parpool options become available after Matlab version: 2013b';
end
try
    nl = numlabs();
catch ME
    if strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
        err_mess = 'License for parallel computer toolbox is available but toolbox is not installed. Can not use parpool parallelization';
    else
        rethrow(ME);
    end
end

if ~isempty(err_mess)
    error('PARALLEL_CONFIG:not_available',err_mess);
end