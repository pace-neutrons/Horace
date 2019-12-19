function [ok, mess] = checkfields (d)
% Check fields for sqw object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid sqw object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)

[ok,mess]=check_sqw(d);

