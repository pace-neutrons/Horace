function   subobj = get_subobj_(obj,sqw_dnd_obj)
% Extract class-defined sub-object from sqw or dnd object for
% further operations. (serialization and damping to hdd)
%
if isa(sqw_dnd_obj,'SQWDnDBase') || is_sqw_struct(sqw_dnd_obj) % get proper sub-object
    if isempty(obj.sqw_prop_name)
        subobj = sqw_dnd_obj;
    else
        % do overload for case when dnd object is provided as input
        if strcmp(obj.sqw_prop_name,'data') && isa(sqw_dnd_obj,'DnDBase')
            subobj = sqw_dnd_obj;
        else
            subobj = sqw_dnd_obj.(obj.sqw_prop_name);
        end
    end
    if isempty(obj.level2_prop_name)
        return;
    end
    subobj = subobj.(obj.level2_prop_name);
else % expect that the requested subobject have been already provided as input
    subobj  = sqw_dnd_obj;
end
