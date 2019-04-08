function [ok, mess] = checkfields (d)
% Check fields for d3d object
%
%   >> [ok, mess] = checkfields (d)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)

% Non-ideal routine:
% Because we go via sqw objects to make d0d,d1d... the only
% way we have to check the fields is to try to construct the dnd.
tmp=d3d(d);
ok=true;
mess='';
