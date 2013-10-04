function is_it = is_herbert_used()
% function checks if Horace uses Herbert or Libisis
%
% $Revision$ ($Date$)
% 
if isempty(strfind(fileparts(which('get_par')),'herbert'))
    is_it = false;
else
    is_it = true;
end




