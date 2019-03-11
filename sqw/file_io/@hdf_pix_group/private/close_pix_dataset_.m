function close_pix_dataset_(obj)
% method closes the pixels dataset (part of the destructor)
if obj.file_space_id_ ~= -1
    H5S.close(obj.file_space_id_);
    obj.file_space_id_ = -1;
end
if obj.pix_dataset_ ~= -1
    H5D.close(obj.pix_dataset_);
    obj.pix_dataset_ = -1;
end
end
