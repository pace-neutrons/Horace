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
