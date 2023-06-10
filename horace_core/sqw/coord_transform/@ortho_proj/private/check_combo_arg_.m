function obj = check_combo_arg_(obj)
% Validate ortho_proj parameters that depend on each other.
%
%
%
% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    error('HORACE:ortho_proj:invalid_argument',...
        'Vectors u and v are collinear or almost collinear');
end

if isempty(obj.w_)
    if obj.type_(3)=='p'
        error('HORACE:ortho_proj:invalid_argument',...
            'Cannot have normalisation type ''p'' for third projection axis unless vector ''w'' is given');
    end
else
    if abs(det([obj.u_(:),obj.v_(:),obj.w_(:)]))<obj.tol_
        error('HORACE:ortho_proj:invalid_argument',...
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
calc_transformation = true;
if ~obj.alatt_defined
    obj.alatt_ = 2*[pi,pi,pi];
    calc_transformation  = false;
end
if ~obj.angdeg_defined
    obj.angdeg_ = 90*ones(1,3);
    calc_transformation  = false;
end

if calc_transformation
    obj.u_to_img_cache_ = [];
    obj.u_offset_cache_ = [];
    obj.ulen_cache_     = [];
    [u_to_img_cache,u_offset_cache,ulen,obj] = ...
        obj.get_pix_img_transformation(4);
    obj.u_to_img_cache_ = u_to_img_cache;
    obj.u_offset_cache_ = u_offset_cache;
    obj.ulen_cache_     = ulen;
else
    obj.u_to_img_cache_ = eye(4);
    obj.u_offset_cache_ = zeros(1,4);
    obj.ulen_cache_     = ones(1,4);
end
