function new_obj = upgrade_file_format(obj,varargin)
%UPGRADE_FILE_FORMAT upgrade file format to the new current preferred file format

[ok,mess,upgrade_range,argi] = parse_char_options(varargin,'-upgrade_range');
if ~ok
    error('HORACE:faccess_sqw_v4:invalid_argument',mess);
end


ff_obj = obj.format_for_object;

new_obj = sqw_formats_factory.instance().get_pref_access(ff_obj);
if ischar(obj.num_dim) % source object is not initiated. Just return
    % non-initialized target object
    return
end
if  upgrade_range
    [new_obj,missing] = new_obj.copy_contents(obj,'-write_mode','-upgrade_range');
else
    [new_obj,missing] = new_obj.copy_contents(obj,'-write_mode');
end
if isempty(missing) % source and target are the same class. Invoke copy constructor only
    return;
end
acc = new_obj.io_mode;
file_exist = is_file(obj.full_filename);
if ~ismember(acc,{'wb+','rb+'})
    new_obj = new_obj.fclose();  % in case the file is still open, and if it does not, makes no harm
    new_obj = new_obj.reopen_to_write(obj.full_filename);
end

if ~file_exist
    return
end

new_obj = obj.do_class_dependent_updates(new_obj,upgrade_range,argi{:});
%
