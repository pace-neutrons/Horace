function obj=set_loader_field(obj,field_name,val)
% this method sets up a field, specific to data loader.
%
if isempty(obj.loader)
    if isempty(val)
        return;
    else
        obj.loader_=loader_nxspe();
        obj.loader_.do_check_combo_arg = obj.do_check_combo_arg;
    end
end
try
    obj.loader_.(field_name)=val;
catch ME
    if strcmp(ME.identifier,'HORACE:a_loader:invalid_argument') && obj.allow_invalid
        obj.isvalid_ = false;
        obj.reason_for_invalid_ = ME.message;
        return;
    else
        rethrow(ME);
    end

end
if obj.do_check_combo_arg_
    obj = obj.check_combo_arg();
end
