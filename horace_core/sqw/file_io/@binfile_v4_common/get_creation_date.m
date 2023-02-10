function cd = get_creation_date(obj)
% get access for creation date of dnd object stored on hdd or
% attached to file loader

if obj.bat_.initialized
    meta = obj.get_dnd_metadata();
    cd = meta.creation_date_str;
elseif ~isempty(obj.sqw_holder)
    if isa(obj.sqw_holder,'DnDBase')
        cd = obj.sqw_holder.creation_date;
    elseif isa(obj.sqw_holder,'sqw')
        cd = obj.sqw_holder.main_header.creation_date;
    else
        cd = get_creation_date@horace_binfile_interface(obj);
    end
else
    cd = get_creation_date@horace_binfile_interface(obj);
end
end
