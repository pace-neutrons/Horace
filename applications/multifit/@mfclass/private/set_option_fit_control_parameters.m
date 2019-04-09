function [val, ok, mess] = set_option_fit_control_parameters (val_in)
% Set fit control parameters
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
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)


ok=true;
mess='';
if nargin==0
    % Default
    rel_step = 1e-4;
    max_iter = 20;
    tol_chisqr = 1e-3;
    val = [rel_step, max_iter, tol_chisqr];
    
else
    % Check values are OK
    if isnumeric(val_in) && numel(val_in)==3
        if size(val_in,1) == 3
            val = val_in(:)';
        else
            val = val_in(:);            
        end
        if val_in(1)<0
            [val,ok,mess] = set_option_error_return('Relative step length must be >= 0'); return
        end
        if val_in(2)<0 || rem(val_in(2),1)~=0
            [val,ok,mess] = set_option_error_return('Maximum number of iterations must be an integer >= 0'); return
        end
    else
        mess={'Fit control parameters must be a numeric vector with three elements:',...
            '[rel_step, max_iter, tol_chisqr]'};
        [val,ok,mess] = set_option_error_return(mess); return
    end
end
