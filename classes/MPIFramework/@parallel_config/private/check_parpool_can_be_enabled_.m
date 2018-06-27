function [ok,err_mess] = check_parpool_can_be_enabled_(obj)
% verify if one can set and use parallel framework based on Matlab parallel
% computing toolbox

err_mess = [];
ok = license('checkout','Distrib_Computing_Toolbox');
if ~ok
    err_mess = 'Licence for parallel computer toolbox is not availible. Can not use parpool parallelization';        
end
if verLessThan('matlab','8.4')
    err_mess =  'Matlab parpool options become availible from Matlab v2013b';            
end
