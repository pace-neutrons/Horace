function [ok, mess] = checkfields (d)
% Check fields for d0d object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

% Non-ideal routine:
% Because we go via sqw objects to make d0d,d1d... the only
% way we have to check the fields is to try to construct the dnd.
tmp=d0d(d);
ok=true;
mess='';
