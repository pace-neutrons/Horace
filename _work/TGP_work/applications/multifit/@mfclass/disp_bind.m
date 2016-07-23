function disp_bind(obj)
% Display the bindings of mfclass object
% Temporary tool.

ss=struct(obj);
[double(ss.free_)';double(ss.bound_)';ss.bound_to_';ss.ratio_']

