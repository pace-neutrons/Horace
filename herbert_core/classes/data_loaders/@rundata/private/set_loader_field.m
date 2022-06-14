function obj=set_loader_field(obj,field_name,val)
% this method sets up a field, specific to data loader.
%
if isempty(obj.loader)
    if isempty(val)
        return;
    else
        obj.loader_=loader_nxspe();
    end
end
obj.loader_.(field_name)=val;
[~,~,obj] = obj.check_combo_arg();
