function new_obj = upgrade_file_format(obj,varargin)
%UPGRADE_FILE_FORMAT upgrade file format to the new current preferred file format

ff_obj = obj.format_for_object;

new_obj = sqw_formats_factory.instance().get_pref_access(ff_obj);
if ischar(obj.num_dim) % source object is not initiated. Just return
    % non-initialized target object
    return
end

[new_obj,missing] = new_obj.copy_contents(obj,'-write_mode');
if isempty(missing) % source and target are the same class. Invoke copy constructor only
    return;
end
acc = new_obj.io_mode;
if ~ismember(acc,{'wb+','rb+'})
    new_obj = new_obj.fclose();  % in case the file is still open, and if it does not, makes no harm
end
[new_obj,file_exist,old_ldr] = new_obj.set_file_to_update();
if ~file_exist
    return
end

new_obj = old_ldr.do_class_dependent_updates(new_obj,varargin{:});
%
