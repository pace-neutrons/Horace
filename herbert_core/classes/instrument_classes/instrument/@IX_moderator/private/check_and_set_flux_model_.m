function obj = check_and_set_flux_model_(obj,val)
% Have to set the flux model parameters to an invalid quantity if sample shape changes
val_old = obj.flux_model_;
if is_string(val)
    if ~isempty(val)
        [ok,mess,fullname] = obj.flux_models_.valid(val);
    else
        [ok,mess,fullname] = obj.flux_models_.valid('uniform');     % For backwards compatibility
    end
    if ok
        obj.flux_model_=fullname;
    else
        error('IX_moderator:invalid_argument',...
            'Moderator flux model: %s',mess)
    end
else
    error('IX_moderator:invalid_argument',...
        'Moderator flux model must be a non-empty character string')
end
if obj.do_check_combo_arg_
    recalc_pdf = strcmp(obj.flux_model_,val_old);
    obj = obj.check_combo_arg(recalc_pdf);
end
