function ok=ge(v1,v2)
% Determine if the first appversion is greater than or equal to the second
%
%   >> ok = ge(v1,v2)

[ok,mess]=logical_operator(v2,v1,'gt');
if ~isempty(mess), error(mess), end
ok=~ok;
