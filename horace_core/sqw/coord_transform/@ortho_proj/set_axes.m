function obj = set_axes(obj, u, v, w, offset)
% Set u,v,w simultaneously
% Avoid problem of setting e.g. u,v, in series, with the new u being parallel
% to the current v, which will correctly throw an error

obj.do_check_combo_arg_ = false;

obj.u_ = u(:)';
obj.v_ = v(:)';

if exist('w','var') && ~isempty(w)
    obj.w_ = w(:)';
end

if exist('offset','var') && ~isempty(offset)
    obj.offset_ = offset(:)';
end

obj.do_check_combo_arg_ = true;
obj = check_combo_arg_(obj);

end
