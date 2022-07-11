function obj = check_combo_arg_(obj)
% Validate lattice parameters which depend on each other.
%

% Check u and v
if norm(cross(obj.u_,obj.v_))/(norm(obj.u_)*norm(obj.v_)) < obj.tol_
    obj.isvalid_ = false;
    obj.reason_for_invalid_ = 'Vectors u and v are collinear or almost collinear';
    return;
end
% check the fields that have to be defined for the object to make sense
if any(obj.undef_fields_)
    undef_fields = obj.fields_to_define_(obj.undef_fields_);
    obj.isvalid_ = false;
    undef_fields_mess = strjoin(undef_fields,'; ');
    obj.reason_for_invalid_ =  sprintf( ...
        'The necessary field(s): %s remain undefined so the lattice is invalid',...
        undef_fields_mess);
    return;
end
obj.isvalid_ = true;
obj.reason_for_invalid_ = '';
