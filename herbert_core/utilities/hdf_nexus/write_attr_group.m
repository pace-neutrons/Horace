function write_attr_group(group_id,data)
% write structure as the group of string attributes
% attached to the specified group. 
% Inputs:
% group_id  -- opened hdf5 group or dataset identifier.
% data      -- a structure to store as the group of attributes.
%
attr_names = fieldnames(data);
for i=1:numel(attr_names)
    
    an = attr_names{i};
    val = data.(an);
    
    if ischar(val)
        type_id = H5T.copy('H5T_C_S1');
        H5T.set_size(type_id, numel(val));
        %type_id = H5T.create('H5T_STRING',numel(val));
        space_id = H5S.create('H5S_SCALAR');
        %loc_id, name, type_id, space_id, acpl_id
        attr_id = H5A.create(group_id,an,type_id,space_id,'H5P_DEFAULT');
        %attr_id = H5A.create(loc_id, name, type_id, space_id, create_plist)
        H5A.write(attr_id,'H5ML_DEFAULT',val);
        
        H5A.close(attr_id);
        H5S.close(space_id);
        H5T.close(type_id);
    end
end
end
