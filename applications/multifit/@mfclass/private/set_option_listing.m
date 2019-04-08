function [val, ok, mess] = set_option_listing (val_in)
% Set listing level
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
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


ok=true;
mess='';
if nargin==0
    % Default
    val = 0;
    
else
    % Check values are OK
    if isnumeric(val_in) && numel(val_in)==1
        val = val_in;
        if val_in(1)<0 || rem(val_in(1),1)~=0
            [val,ok,mess] = set_option_error_return('Fit listing output level must be an integer >= 0'); return
        end
    else
        [val,ok,mess] = set_option_error_return('Fit listing output level must be an integer >= 0'); return
    end
end
