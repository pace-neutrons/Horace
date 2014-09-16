function ok=lt(v1,v2)
% Determine if the first appversion is less than the second
%
%   >> ok = lt(v1,v2)

[ok,mess]=logical_operator(v2,v1,'gt');
if ~isempty(mess), error(mess), end
