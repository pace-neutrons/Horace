function [ok,mess,obj] = check_combo_arg_(obj)
% Validate lattice parameters which depend on each other.
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
% check the fields that have to be defined for the object to make sense
if any(obj.undef_fields_)
    undef_fields = obj.fields_to_define_(obj.undef_fields_);
    undef_fields_mess = strjoin(undef_fields,'; ');
    mess = sprintf('The necessary field(s): %s remain undefined so the lattice is invalid',...
        undef_fields_mess);
    ok=false;
    obj.isvalid_ = false;
end

