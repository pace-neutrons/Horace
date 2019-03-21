function write_pix_range_(obj)

group_name = 'pix_range';
type_id = H5T.copy('H5T_NATIVE_DOUBLE');
space_id = H5S.create_simple(2,[2,9],[2,9]);
if H5L.exists(obj.pix_group_id_,group_name,'H5P_DEFAULT')
    dset_id = H5D.open(obj.pix_group_id_,group_name,'H5P_DEFAULT');    
else
    dset_id = H5D.create(obj.pix_group_id_,group_name,type_id,space_id,'H5P_DEFAULT');    
end
H5D.write(dset_id,type_id, space_id,space_id,'H5P_DEFAULT',double([obj.pix_min_,obj.pix_max_]));
%
H5D.close(dset_id);
H5S.close(space_id);
H5T.close(type_id)


