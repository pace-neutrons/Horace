function obj =set_as_tmp_obj_(obj,filename)
%SET_AS_TMP_OBJ_ mark file - the base of the filebacked object to be
% deleted when object build over this file goes out of scope.

if nargin == 1
    % pix always have real filename while higher level accessor may be
    % mangled. For historical reasons. May be its wrong.
    filename = obj.pix.full_filename;
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
