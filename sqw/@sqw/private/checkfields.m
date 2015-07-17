function [ok, mess] = checkfields (d)
% Check fields for sqw object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid sqw object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[ok,mess]=check_sqw(d);
