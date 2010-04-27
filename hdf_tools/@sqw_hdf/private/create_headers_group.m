function this = create_headers_group(this)
% creates unique group with the name, specified by 
% this.components_Group_Name and attribute, which keeps the number of the
% contributing headers;
%
% side_effects:
% initiates for further access:
% this.components_group_ID and this.comp_counter_attrID
% 
% this.compogroup_is_opened is set to true;
%
% $Revision$ ($Date$)
%
%
% *** > should we initially try to open?
try
   this.components_group_ID=H5G.open(this.sqw_file_ID,this.components_Group_Name);    
   this.comp_counter_attrID = H5A.open_name(this.components_group_ID,this.components_counter_attr);
catch
    this.components_group_ID=H5G.create(this.sqw_file_ID,this.components_Group_Name,'H5P_DEFAULT', 'H5P_DEFAULT', 'H5P_DEFAULT');
    space = H5S.create ('H5S_SCALAR');
    this.comp_counter_attrID = H5A.create (this.components_group_ID, this.components_counter_attr,'H5T_NATIVE_DOUBLE', space, 'H5P_DEFAULT');
    H5S.close(space);
end

H5A.write (this.comp_counter_attrID,'H5T_NATIVE_DOUBLE', this.components_counter); 


this.compogroup_is_opened=true;
