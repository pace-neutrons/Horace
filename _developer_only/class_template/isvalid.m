function [ok, mess] = isvalid (w)
% Check fields for data_array object
%
%   >> [ok, mess] = isvalid (w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.

% Generic method. Needs specific private function checkfields

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)

[ok,mess] = checkfields(struct(w));
