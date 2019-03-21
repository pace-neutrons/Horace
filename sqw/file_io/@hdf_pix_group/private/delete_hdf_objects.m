function delete_hdf_objects(obj)
% destructor to close all hdf5 objects and, if enabled, destroy mex info
%
if obj.io_mem_space_ ~= -1
    H5S.close(obj.io_mem_space_);
end
if obj.pix_data_id_ ~= -1
    H5T.close(obj.pix_data_id_);
    obj.pix_data_id_ = -1;
end
close_pix_dataset_(obj);
%
if obj.pix_group_id_ ~= -1
    H5G.close(obj.pix_group_id_);
end
if ~isempty(obj.mex_read_handler_)
    obj.mex_read_handler_ = hdf_mex_reader('close',obj.mex_read_handler_);
end
if isempty(obj.old_style_fid_)
    if ~isempty(obj.fid_)
        H5F.close(obj.fid_)
        obj.fid_ = [];
    end
else
    H5G.colse(obj.fid_);
    H5F.close(obj.old_style_fid_)
    obj.fid_ = [];
    obj.old_style_fid_=[];
end
obj.use_mex_to_read_ = [];
obj.matlab_read_info_cache_ ={};
obj.pix_min_  =  inf(9,1);
obj.pix_max_  = -inf(9,1);

