function   changed_obj = set_subobj_(obj,sqw_dnd_obj,part_to_set)
% Set up class-defined sub-object at proper place of input
% sqw_dnd_object. The operation is opposite to get_subobj and
% used during recovery of the stored sqw object from binary file.

if isempty(obj.base_prop_name)
    obj_level1 = sqw_dnd_obj;
else
    % do overload for case when dnd object is provided as input
    if strcmp(obj.base_prop_name,'data') && isa(sqw_dnd_obj,'DnDBase')
        dnd_obj = true;
        obj_level1 = sqw_dnd_obj;
    else
        dnd_obj = false;        
        obj_level1 = sqw_dnd_obj.(obj.base_prop_name);
    end
end
if isempty(obj.level2_prop_name)
    obj_level1.(obj.base_prop_name) = part_to_set;
    changed_obj = obj_level1;
    return;
end
obj_level1.(obj.level2_prop_name) = part_to_set;
if dnd_obj
    changed_obj = obj_level1;
    return;
end
changed_obj = sqw_dnd_obj;
changed_obj.(obj.base_prop_name) = obj_level1;

