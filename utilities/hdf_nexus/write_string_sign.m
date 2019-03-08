function write_string_sign(group_id,ds_name,name,attr_name,attr_cont)
% write string dataset with possible attribute
% Such structure is used in NeXus e.g. to indicate that this file is nxspe file
% and on number of other occasions
%

filetype = H5T.copy ('H5T_FORTRAN_S1');
H5T.set_size (filetype, numel(name));
memtype = H5T.copy ('H5T_C_S1');
H5T.set_size (memtype, numel(name));

space = H5S.create_simple (1,1, 1);
dataset_id = H5D.create (group_id, ds_name, filetype, space, 'H5P_DEFAULT');
H5D.write (dataset_id, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', name);

write_attr_group(dataset_id,struct(attr_name,attr_cont));
H5D.close(dataset_id);
H5S.close(space);
H5T.close(filetype);
H5T.close(memtype);
end
