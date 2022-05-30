function [ok, mess, wout] = check_combo_arg (w)
% Check validity of interdependent fields
%
%   >> [ok, mess,obj] = check_combo_arg(w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.

% Generic method. Needs specific private function checkfields

% Original author: T.G.Perring
%
% 	15 August 2009  Pass w to checkfields, so that checkfields can alter fields
%                   of object. Because checkfields is a private method, the fields
%                   can be altered using w.x=<new value> *without* calling
%                   set.m. (T.G.Perring)
%  03/04/2017       Checking only combo aruments as ivalid arguments can
%                   not be set up separately using class setters 
[ok,mess,wout] = check_combo_arg_(w);
if ~ok && nargout<2 
    error('HORACE:ortho_proj:runtime_error',...
        'ortho_proj class instance is invalid: %s',...
        mess);
end
