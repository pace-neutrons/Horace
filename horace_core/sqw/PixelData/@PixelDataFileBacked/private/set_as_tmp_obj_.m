function obj =set_as_tmp_obj_(obj,filename)
%SET_AS_TMP_OBJ_ mark file-base of the filebacked object marked for
% deleteon when object build over the file goes out of scope.

if nargin == 1
    filename = obj.full_filename;
end
if isempty(obj.tmp_file_holder_)
    obj.tmp_file_holder_ = TmpFileHandler(filename,true);
else
    if strcmp(obj.tmp_file_holder_.file_name,filename)
        obj.tmp_file_holder_.unlock();
    else
        obj.tmp_file_holder_ = TmpFileHandler(filename,true);
    end
end
