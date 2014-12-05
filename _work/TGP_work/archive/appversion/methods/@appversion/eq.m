function ok=eq(v1,v2)
% Determine if the appversion objects are identical
%
%   >> ok = eq(v1,v2)

[ok,mess]=logical_operator(v1,v2,'eq');
if ~isempty(mess), error(mess), end
