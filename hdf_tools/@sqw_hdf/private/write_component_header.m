function this=write_component_header(this,header_data)
% the function writes the header data structure into new hdf-file place
% defined by components_Group_Name string
%
% inputs: 
% header_data       -- structure with data to write
%
% side effects:
% increases the counder of contributing spe headers
    
this.components_counter=this.components_counter+1;
%
subgroup_name     = [this.component_subgroup_name,num2str(this.components_counter)];

data_field_names = fieldnames(header_data);
% write fields
write_fields_list_attr(this.components_group_ID,subgroup_name,data_field_names,header_data);

% update headers counter attribute;
H5A.write (this.comp_counter_attrID, 'H5T_NATIVE_DOUBLE', this.components_counter); 

    

     
 