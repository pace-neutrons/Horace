function ok=ne(v1,v2)
% Determine if the appversion objects are not identical
%
%   >> ok = ne(v1,v2)

[ok,mess]=logical_operator(v1,v2,'eq');
if ~isempty(mess), error(mess), end
ok=~ok;
