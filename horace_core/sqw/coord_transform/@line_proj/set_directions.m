function obj = set_directions(obj, u, v, w, offset)
% Set u,v,w simultaneously
% Avoid problem of setting e.g. u,v, in series, with the new u being parallel
% to the current v, which will correctly throw an error

obj.do_check_combo_arg_ = false;

obj.u = u;
obj.v = v;

if exist('w','var') && ~isempty(w)
    obj.w = w;
end

if exist('offset','var') && ~isempty(offset)
    obj.offset = offset;
end

obj.do_check_combo_arg_ = true;
obj = obj.check_combo_arg();

end
