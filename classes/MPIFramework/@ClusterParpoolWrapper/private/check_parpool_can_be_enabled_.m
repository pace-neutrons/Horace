function check_parpool_can_be_enabled_(obj)
% verify if one can set and use parallel framework based on Matlab parallel
% computing toolbox

err_mess = [];
ok = license('checkout','Distrib_Computing_Toolbox');
if ~ok
    err_mess = 'License for parallel computer toolbox is not available. Can not use parpool parallelization';
end
if verLessThan('matlab','8.4')
    err_mess =  'Matlab parpool options become available from Matlab v2013b';
end

if ~isempty(err_mess)
    error('PARALLEL_CONFIG:not_avalable',err_mess);
end