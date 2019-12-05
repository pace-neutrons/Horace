function [ok, mess] = checkfields (d)
% Check fields for d2d object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

% Non-ideal routine:
% Because we go via sqw objects to make d0d,d1d... the only
% way we have to check the fields is to try to construct the dnd.
tmp=d2d(d);
ok=true;
mess='';

