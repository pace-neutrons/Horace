function obj = check_and_set_fm_params_(obj,val)
pf_old = obj.pf_;
if isnumeric(val) && (isempty(val) || isvector(val))
    if isempty(val)
        obj.pf_=[];
    else
        obj.pf_=val(:)';    % make a row vector
    end
else
    obj.pf_=val;
end

if obj.do_check_combo_arg_
    recalc_pdf = ~isequal(pf_old,obj.pf_);
    obj = obj.check_combo_arg(recalc_pdf);
end
