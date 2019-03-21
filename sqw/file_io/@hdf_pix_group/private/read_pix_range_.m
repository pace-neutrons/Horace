function read_pix_range_(obj)
group_name = 'pix_range';

type_id = H5T.copy('H5T_NATIVE_DOUBLE');
space_id = H5S.create_simple(2,[2,9],[2,9]);
dset_id = H5D.open(obj.pix_group_id_,group_name,'H5P_DEFAULT');    
pix_range_= H5D.read(dset_id,type_id, space_id,space_id,'H5P_DEFAULT');
obj.pix_min_ = pix_range_(:,1);
obj.pix_max_ = pix_range_(:,2);
H5D.close(dset_id);
H5S.close(space_id);
H5T.close(type_id)


