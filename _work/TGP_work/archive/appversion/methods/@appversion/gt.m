function ok=gt(v1,v2)
% Determine if the first appversion is greater than the second
%
%   >> ok = gt(v1,v2)

[ok,mess]=logical_operator(v1,v2,'gt');
if ~isempty(mess), error(mess), end
