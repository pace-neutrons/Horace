function   subobj = get_subobj_(obj,sqw_dnd_obj)
% Extract class-defined sub-object from sqw or dnd object for
% further operations. (serialization and damping to hdd)
%
if isempty(obj.base_prop_name)
    subobj = sqw_dnd_obj;
else
    % do overload for case when dnd object is provided as input
    if strcmp(obj.base_prop_name,'data') && isa(sqw_dnd_obj,'DnDBase')
        subobj = sqw_dnd_obj;
    else
        subobj = sqw_dnd_obj.(obj.base_prop_name);
    end
end
if isempty(obj.level2_prop_name)
    return;
end
subobj = subobj.(obj.level2_prop_name);
