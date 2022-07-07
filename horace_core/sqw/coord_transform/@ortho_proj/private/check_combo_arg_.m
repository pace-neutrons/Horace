function [ ok,mess,obj] = check_combo_arg_(obj)
% Validate ortho_proj parameters that depend on each other.
%
%
%
mess ='';
% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    mess = 'Vectors u and v are collinear or almost collinear';
end

if isempty(obj.w_)
    if obj.type_(3)=='p'
        wrong_p='Cannot have normalisation type ''p'' for third projection axis unless vector ''w'' is given';
        if isempty(mess)
            mess = wrong_p;
        else
            mess = [mess,' ; ',wrong_p];
        end
    end
else
    if abs(det([obj.u_(:),obj.v_(:),obj.w_(:)]))<obj.tol_
        wu_coplanar='Vector w is coplanar (or almost coplanar) with u and v';
        if isempty(mess)
            mess = wu_coplanar;
        else
            mess = [mess,' ; ',wu_coplanar];
        end
    end
end
if ~isempty(mess)
    error('HORACE:ortho_proj:invalid_argument',mess);
end

