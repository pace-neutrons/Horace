function obj = finish_dump_(obj,page_op)
% complete pixel write operation, close writing to the target file and
% open pixel dataset for read operations.
%
%
wh = page_op.write_handle;
init_info = wh.release_pixinit_info();
if wh.is_tmp_file
    obj = obj.set_as_tmp_obj(wh.write_file_name);
end
obj = obj.init(init_info);
