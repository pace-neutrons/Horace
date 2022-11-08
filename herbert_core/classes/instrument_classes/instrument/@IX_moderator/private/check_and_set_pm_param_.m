function obj = check_and_set_pm_param_(obj,val)
val_old = obj.pp_;
if isnumeric(val) && (isempty(val) || isvector(val))
    if isempty(val)
        obj.pp_=[];
    else
        obj.pp_=val(:)';    % make a row vector
    end
else
    obj.pp_=val;
end
obj.mandatory_field_set_(4) = true;
if obj.do_check_combo_arg_
    % Must check the number of parameters is consistent with the pulse model    
    if isnumeric(obj.pp_)
        recalc_pdf = ~((numel(obj.pp_)==numel(val_old)) && ...
            (all(obj.pp_==val_old)||isequal(obj.pp_,val_old)));
    elseif isnan(obj.n_pp_(obj.pulse_model_))
        recalc_pdf = ~isequal(obj.pp_,val_old);
    end
    obj = obj.check_combo_arg(recalc_pdf);
end
