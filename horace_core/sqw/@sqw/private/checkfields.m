function [ok, mess] = checkfields (d)
% Check fields for sqw object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid sqw object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

[ok,mess]=check_sqw(d);
