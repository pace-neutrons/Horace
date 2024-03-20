function obj = check_combo_arg_(obj)
% Validate line_proj parameters that depend on each other.
%
%
%
if obj.alatt_defined && obj.angdeg_defined
    [u,v,w,type,nonortho]=obj.uv_from_u_to_rlu_legacy(obj.u_to_rlu,obj.img_scales);
    u = obj.check_and_brush3vector(u);
    v = obj.check_and_brush3vector(v);
    w = obj.check_and_brush3vector(w);
    obj.uvw_cache_ = [u(:),v(:),w(:)];
    obj.type_ = type;
    obj.nonorthogonal_ = nonortho;
end
