function init_(obj,place,n_pixels,chunk_size)
% initialize hdf_pixel_group within the nxspe file to perform IO operations

if ischar(place)
    [file_id,fid,file_h,data_version] = open_or_create_nxsqw_head(place);    
    obj.fid_ = file_id;
else
    fid = place;
end

%
if exist('n_pixels','var')|| exist('chunk_size','var')
    pix_size_defined = true;
else
    pix_size_defined = false;
    n_pixels = [];
end
if exist('chunk_size','var')
    obj.chunk_size_ = chunk_size;
else
    chunk_size = obj.chunk_size_;
end

group_name = 'pixels';

obj.pix_data_id_ = H5T.copy('H5T_NATIVE_FLOAT');
if H5L.exists(fid,group_name,'H5P_DEFAULT')
    open_existing_dataset_(obj,fid,pix_size_defined,n_pixels,chunk_size,group_name);
else
    if nargin<1
        error('HDF_PIX_GROUP:invalid_argument',...
            'the pixels group does not exist but the size of the pixel dataset is not specified')
    end
    if ~pix_size_defined
        error('HDF_PIX_GROUP:invalid_argument',...
            'Attempting to create new pixels group but the pixel number is not defined');
    end
    create_pix_dataset_(obj,fid,group_name,n_pixels,chunk_size);
end
block_dims = [obj.chunk_size_,9];
obj.io_mem_space_ = H5S.create_simple(2,block_dims,block_dims);
obj.io_chunk_size_ = obj.chunk_size_;
%H5P.close(dcpl_id);
%H5P.close(pix_dapl_id );

