function obj = check_combo_arg_(obj)
% Validate lattice parameters which depend on each other.
%

% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    if obj.allow_invalid_
        obj.isvalid_ = false;
    else
        error('HORACE:oriented_lattice:invalid_argument', ...
            'Vectors u and v are collinear or almost collinear');
    end
end
% check the fields that have to be defined for the object to make sense
if any(obj.undef_fields_)
    undef_fields = obj.fields_to_define_(obj.undef_fields_);
    if obj.allow_invalid_
        obj.isvalid_ = false;
    else
        undef_fields_mess = strjoin(undef_fields,'; ');
        error('HORACE:oriented_lattice:invalid_argument', ...
            'The necessary field(s): %s remain undefined so the lattice is invalid',...
            undef_fields_mess);
    end
end
obj.isvalid_ = true;
