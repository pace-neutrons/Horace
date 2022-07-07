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
obj.loader_.(field_name)=val;


if obj.do_check_combo_arg_
    obj = obj.check_combo_arg();
end
