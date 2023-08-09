function obj = check_and_set_pulse_model_(obj,val)
%
val_old = obj.pulse_model_;
if istext(val) && ~isempty(val)
    [ok,mess,fullname] = obj.pulse_models_.valid(char(val));
    if ok
        obj.mandatory_field_set_(3) = true;
        obj.pulse_model_=fullname;
    else
        error('HERBERT:IX_moderator:invalid_argument',...
            ['Moderator pulse shape model: ',mess])
    end
else
    error('HERBERT:IX_moderator:invalid_argument',...
        ['Moderator pulse shape model must be a non-empty character string.\n' ...
        'Its type is %s and value %s'], ...
        class(val),disp2str(val));
end

if obj.do_check_combo_arg_
    recalc_pdf = strcmp(obj.pulse_model,val_old);
    obj = obj.check_combo_arg(recalc_pdf);
end
%