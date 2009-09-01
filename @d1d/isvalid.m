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
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

[ok,mess] = checkfields(struct(w));
