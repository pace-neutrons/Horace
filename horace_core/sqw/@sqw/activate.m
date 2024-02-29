function obj = activate(obj,new_file)
% Restore access to a file, previously closed by deactivate
% operation, possibly using new file name.
%
% Restores tmp obj status for tmp files.
if nargin == 1 || isempty(new_file)
    new_file = obj.pix.full_filename;
end
[obj.pix,is_tmp_file_set] = obj.pix.activate(new_file,true);
if is_tmp_file_set
    obj = obj.set_as_tmp_obj(new_file);
else
    obj.full_filename = obj.pix.full_filename;
end
