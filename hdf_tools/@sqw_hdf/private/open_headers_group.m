function this=open_headers_group(this)
% function opens existing sqw_hdf headers group and prepares this group for
% furher file operations
% It also reads the number of the data headers included into the file. 
% 
try
 this.components_group_ID = H5G.open(this.sqw_file_ID,this.components_Group_Name);    
 this.comp_counter_attrID = H5A.open_name(this.components_group_ID,this.components_counter_attr);
catch Err;
    % may be it is one-sqw file?
    
    error('HORACE:hdf_tools','open_headers_group: can not open the group %s, Err: %s',this.components_Group_Name,Err.message);
end

this.components_counter=H5A.read(this.comp_counter_attrID, 'H5T_NATIVE_DOUBLE');
this.compogroup_is_opened=true;


