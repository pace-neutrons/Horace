function   changed_obj = set_subobj_(obj,sqw_dnd_obj,part_to_set)
% Set up class-defined sub-object at proper place of input
% sqw_dnd_object. The operation is opposite to get_subobj and
% used during recovery of the stored sqw object from binary file.

if isempty(obj.sqw_prop_name)
    obj_level1 = sqw_dnd_obj;
    top_level_prop = true;
else
    % do overload for case when dnd object is provided as input
    settind_dnd = strcmp(obj.sqw_prop_name,'data');
    if settind_dnd && isa(sqw_dnd_obj,'DnDBase')
        top_level_prop = true;
        obj_level1 = sqw_dnd_obj;
    else
        top_level_prop = false;
        obj_level1 = sqw_dnd_obj.(obj.sqw_prop_name);
    end
end
if ~(isstruct(obj_level1)||isempty(obj_level1)) % then its sqw/dnd object
    % disable internal checks for validity of dnd object
    % as partial setting of an object can make it invalid
    % Final check have to be performed after loader is completed
    obj_level1.do_check_combo_arg = false;
end

if isempty(obj.level2_prop_name)
    obj_level1.(obj.sqw_prop_name) = part_to_set;
    changed_obj = obj_level1;
    return;
end
obj_level1.(obj.level2_prop_name) = part_to_set;
if top_level_prop
    changed_obj = obj_level1;
    return;
end
changed_obj = sqw_dnd_obj;
changed_obj.(obj.sqw_prop_name) = obj_level1;
