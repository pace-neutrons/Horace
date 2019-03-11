function open_existing_dataset_(obj,fid,pix_size_defined,n_pixels,chunk_size,group_name)
% opens existing pixels dataset within opened hdf file and selected group
%
%
% $Revision$ ($Date$)
%
%
obj.pix_group_id_ = H5G.open(fid,group_name);
if obj.pix_group_id_<0
    error('HDF_PIX_GROUP:runtime_error',...
        'can not open pixels group');
end
obj.pix_dataset_ = H5D.open(obj.pix_group_id_,group_name);
if obj.pix_dataset_<0
    error('HDF_PIX_GROUP:runtime_error',...
        'can not open pixels dataset');
end
obj.file_space_id_  = H5D.get_space(obj.pix_dataset_);
if obj.file_space_id_<0
    error('HDF_PIX_GROUP:runtime_error',...
        'can not retrieve pixels datasets dataspace');
end
[~,h5_dims,h5_maxdims] = H5S.get_simple_extent_dims(obj.file_space_id_);
obj.max_num_pixels_ = h5_dims(1);
if h5_maxdims(2) ~= 9
    error('HDF_PIX_GROUP:runtime_error',...
        'wrong size of pixel dataset. dimenison 1 has to be 9 but is: %d',...
        h5_maxdims(2));
end
dcpl_id=H5D.get_create_plist(obj.pix_dataset_);
[~,h5_chunk_size] = H5P.get_chunk(dcpl_id);
obj.chunk_size_ = h5_chunk_size(1);
if pix_size_defined
    n_pixels =  obj.get_extended_npix_(n_pixels,chunk_size);
    if obj.chunk_size_ ~= chunk_size
        error('HDF_PIX_GROUP:invalid_argument',...
            'Current chunk %d, new chunk %d. Can not change the chunk size of the existing dataset.',...
            obj.chunk_size_,chunk_size)
    elseif obj.max_num_pixels_ ~=n_pixels
        H5D.set_extent(obj.pix_dataset_,[n_pixels,9]);
        obj.max_num_pixels_ = n_pixels;
        obj.file_space_id_  = H5D.get_space(obj.pix_dataset_);
    end
end
pix_dapl_id = H5D.get_access_plist(obj.pix_dataset_);
[obj.cache_nslots_,obj.cache_size_]=H5P.get_chunk_cache(pix_dapl_id);
%chunk_size = obj.chunk_size_;
