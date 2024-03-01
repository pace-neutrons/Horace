function fn = get_full_filename_(obj)
% getter for full sqw object filename
if isempty(obj.tmp_file_holder_)
    fn = obj.main_header.full_filename;
else
    fn = obj.tmp_file_holder_.file_name;
end
