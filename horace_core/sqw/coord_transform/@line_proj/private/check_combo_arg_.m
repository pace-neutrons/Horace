function obj = check_combo_arg_(obj)
% Validate line_proj parameters that depend on each other.
%
%
%
% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    error('HORACE:line_proj:invalid_argument',...
        'Vectors u and v are collinear or almost collinear');
end

if isempty(obj.w_)
    if obj.type_(3)=='p'
        error('HORACE:line_proj:invalid_argument',...
            'Cannot have normalisation type ''p'' for third projection axis unless vector ''w'' is given');
    end
else
    if abs(det([obj.u_(:),obj.v_(:),obj.w_(:)]))<obj.tol_
        error('HORACE:line_proj:invalid_argument',...
            'Vector w is coplanar (or almost coplanar) with u and v');
    end
end
if ~obj.type_is_defined_explicitly_
    if isempty(obj.w)
        obj.type_(3) = 'r';
    else
        obj.type_(3) = 'p';
    end
end
% do not bother calculating real transformation if lattice is undefined
% more important for debugging than anything else, as you do not debug
% empty constructor
calc_transformation  = false;
if obj.alatt_defined && obj.angdeg_defined
    calc_transformation = true;
end

if calc_transformation
    obj.q_to_img_cache_ = [];
    obj.q_offset_cache_ = [];
    obj.img_scales_     = [];
    [q_to_img_cache,q_offset_cache,img_scales,obj] = ...
        obj.get_pix_img_transformation(4);
    obj.q_to_img_cache_ = q_to_img_cache;
    obj.q_offset_cache_ = q_offset_cache;
    obj.img_scales_     = img_scales;
else
    obj.q_to_img_cache_ = eye(4);
    obj.q_offset_cache_ = zeros(4,1);
    obj.img_scales_ = ones(1,4);
end
