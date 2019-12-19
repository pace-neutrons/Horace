function  create_pix_dataset_(obj,fid,group_name,n_pixels,chunk_size)
% Create new pixels dataset within existing hdf file
%
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%
%
obj.pix_group_id_ = H5G.create(fid,group_name,10*numel(group_name));
write_attr_group(obj.pix_group_id_,struct('NX_class','NXdata'));


obj.max_num_pixels_ = get_extended_npix_(n_pixels,chunk_size);
dims = [obj.max_num_pixels_,9];
chunk_dims = [chunk_size,9];
%
% size of the pixel cache
pn = 521; %primes(2050);
obj.cache_nslots_ = pn(end);
cache_n_bytes = obj.cache_nslots_*chunk_size*9*4;
%cache_n_bytes     = 0; %chunk_size*9*4;
obj.cache_size_   = cache_n_bytes;


dcpl_id = H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(dcpl_id, chunk_dims);
pix_dapl_id = H5P.create('H5P_DATASET_ACCESS');
H5P.set_chunk_cache(pix_dapl_id,obj.cache_nslots_,cache_n_bytes,1);

obj.file_space_id_ = H5S.create_simple(2,dims,[H5ML.get_constant_value('H5S_UNLIMITED'),9]);

obj.pix_dataset_= H5D.create(obj.pix_group_id_,group_name,...
    obj.pix_data_id_ ,obj.file_space_id_,...
    'H5P_DEFAULT',dcpl_id,pix_dapl_id);



