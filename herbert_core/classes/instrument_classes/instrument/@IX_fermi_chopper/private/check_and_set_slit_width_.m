function obj =check_and_set_slit_width_(obj,val)
% check slit width value is acceptable and store its value
% to the class
val_old = obj.slit_width_;
if isscalar(val) && isnumeric(val) && val>=0
    obj.mandatory_field_set_(5) = true;
    obj.slit_width_=val;
    if obj.slit_spacing_ < obj.slit_width_
        old_slit_spacing = obj.slit_spacing_;
        obj.slit_spacing = obj.slit_width;
    else
        old_slit_spacing = [];
    end
else
    error('HERBERT:IX_fermi_chopper:invalid_argument', ...
        'Slit width must be a numeric scalar greater or equal to zero. It is %s',...
        disp2str(val));
end

if obj.do_check_combo_arg_
    if ~isempty(old_slit_spacing)
        log_level = get(hor_config,'log_level');
        if log_level>1
            warning('HORACE:IX_fermi_chopper:invalid_argument',...
                'slit spacing=%g was smaller then slit width=%g so changed to be equal to slit width',...
                old_slit_spacing,obj.slit_width)
        end
    end
    recompute_pdf = obj.slit_width_~=val_old;
    obj = obj.check_combo_arg(recompute_pdf);
end
