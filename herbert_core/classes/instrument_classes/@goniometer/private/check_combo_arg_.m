function obj = check_combo_arg_(obj)
% Validate lattice parameters which depend on each other.
%

% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    error('HERBERT:goniometer:invalid_argument',...
        'Vectors u (%s) and v (%s) are collinear or almost collinear',...
        mat2str(obj.u_),mat2str(obj.v_));
end
