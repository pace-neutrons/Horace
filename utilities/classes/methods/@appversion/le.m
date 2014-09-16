function [ok,mess]=le(v1,v2)
% Determine if the first appversion is less than or equal to the second
%
%   >> ok = le(v1,v2)

[ok,mess]=logical_operator(v1,v2,'gt');
if ~isempty(mess), error(mess), end
ok=~ok;
