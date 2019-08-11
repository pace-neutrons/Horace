function [val, ok, mess] = set_option_selected (val_in)
% Set 'selected' option
%
% Standard format function: must allow the following:
%
% Fill default:
%   >> [val, ok, mess] = set_option_optname
%
% Set value, checking if ok and parsing if necessary; mess='' if OK, error message if not
%   >> [val, ok, mess] = set_option_optname (val_in)


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


ok=true;
mess='';
if nargin==0
    % Default
    val = true;
    
else
    % Check values are OK
    if islognumscalar(val_in)
        val = logical(val_in);
    else
        [val,ok,mess] = set_option_error_return('''selected'' option must a logical scalar (or numeric 0 or 1)'); return
    end
end
