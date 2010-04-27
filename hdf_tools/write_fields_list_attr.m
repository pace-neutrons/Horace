function write_fields_list_attr(file_ID,Group_Name,fields_list,data_structure)
% function writes selected fields of the structure data_structure 
% into peviously opened hdf file under global group name preserving the 
% structure of the data in the data_structure, namely, each field in the
% structure would correspond to an attribute associated with the group. 
%
% Because of HDF5 bug, the function has to be used to wrtie data to
% interpret by read_field_list_attr function only
%
%usage:
%    write_fields_list(file_ID,Group_Name,fields_list,data_structure)
%
% file_ID  --  the ID of the the opened HDF5 file (resulting from
%              H5F.open() of H5f.create operation)
% Group_Name - common name of the complex dataset which corresponds to the
%              data_structure we are writting
% fields_list- the list of the names of fields to be written to the file
%              All these fields have to be present in the data_structure
%              or error will be thrown. 
% data_structure -- the structure which keeps all data to be written to the
%                   HDF5 file
%
%             key words are used to incode unsupported data formats 
%             These key-words can not be present in the fiedls list:
% EMPTY_  and FILLER_
%
% V1: AB on 1/03/2010
%
% $Revision$ ($Date$)
%

%if Group_Name(1)~='/'
%    Group_Name=['/',Group_Name];
%end
if dataset_exist(file_ID,Group_Name)
    groupID=H5G.open(file_ID, Group_Name);        
else
    try
        groupID=H5G.create(file_ID, Group_Name, 1000);
        % errors should be clearned here
    catch Err
        message=['write_fields_list=> can not either open or create the group ',Group_Name,' Error: ',Err.message];
        error('HORACE:hdf_tools',message);
    end
end

write_attributes_list(groupID,fields_list,data_structure)

H5G.close(groupID);


