function obj = set_axes (obj, u, v, w)
% Set u,v,w simultaneously
% Avoid problem of setting e.g. u,v, in series, with the new u being parallel
% to the current v, which will correctly throw an error

obj = check_and_set_u_(obj,u);
obj = check_and_set_v_(obj,v);
if exist('w','var')
    obj = check_and_set_w_(obj,w);
end

[ok,mess,obj] = check_combo_arg_(obj);
if ~ok
    error(mess)
end
