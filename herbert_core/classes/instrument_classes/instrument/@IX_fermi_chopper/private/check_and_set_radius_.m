function obj = check_and_set_radius_(obj,val)
% verify input radius and set it to class if correct

val_old = obj.radius_;
if isscalar(val) && isnumeric(val) && val>=0
    obj.mandatory_field_set_(3) = true;
    obj.radius_=val;
else
    error('HERBERT:IX_fermi_chopper:invalid_argument', ...
        'Fermi chopper radius must be a numeric scalar greater or equal to zero. It is %s',...
        disp2str(val));
end
if obj.do_check_combo_arg_ % not a check but done this way to avoid
    % pdf recalculations if multiple properties are set
    recompute_pdf = obj.radius_~=val_old; % recompute the lookup table
    obj = obj.check_combo_arg(recompute_pdf);
end
