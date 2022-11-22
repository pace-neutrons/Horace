function obj = check_and_set_frequency_(obj,val)

val_old = obj.frequency_;
if isscalar(val) && isnumeric(val) && val>=0
    obj.mandatory_field_set_(2) = true;
    obj.frequency_=val;
else
    error('HERBERT:IX_fermi_chopper:invalid_argument', ...
        'Frequency must be a numeric scalar greater or equal to zero. It is %s',...
        disp2str(val));
end
if obj.do_check_combo_arg_ % not a check but done this way to avoid
    % pdf recalculations if multiple properties are set
    recompute_pdf = obj.frequency_~=val_old; % recompute the lookup table
    obj = obj.check_combo_arg(recompute_pdf);
end
