function [ ok,mess,obj] = check_combo_arg_(obj)
% Validate projection parameters that depend on each other.
%
%
%
ok=true;
mess ='';
obj.isvalid_ = true;
% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    mess = 'Vectors u and v are collinear or almost collinear';
    ok=false;
    obj.isvalid_ = false;
end
