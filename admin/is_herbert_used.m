function is_it = is_herbert_used()
% function checks if Horace uses Herbert or Libisis
%
% $Revision: 587 $ ($Date: 2011-11-25 16:42:24 +0000 (Fri, 25 Nov 2011) $)
% 
if isempty(strfind(fileparts(which('get_par')),'herbert'))
    is_it = false;
else
    is_it = true;
end




