function header=read_component_headers(this,field_names,is_column)
% function reads the list of headers from the contributing sqw(spe) files
%
%>> header=read_component_headers(this,[field_names,is_column])
% 
%
% $Revision$ ($Date$)
%
if ~this.compogroup_is_opened
    error('HORACE:hdf_tools','read_component_headers->the group of headers is not opened or does not exist');
end

if nargin~=3
    % identify fields requested to read
    data_struct = build_default_spe_structure(this);
    % *** > should we read exisiting fiedls instead?
    [field_names,is_column] = fieldnames_and_shapes(data_struct);
    clear data_struct;
else
    if numel(field_names)~=numel(is_column)    
       error('HORACE:hdf_tools','read_component_headers->roup of headers is not opened or does not exist');
    end
end

%num_fields = numel(field_names);

header = cell(this.components_counter,1);
for i=1:this.components_counter
     subgroup_name=[this.component_subgroup_name,num2str(i)];
     try
           group_ID=H5G.open(this.components_group_ID,subgroup_name);
     catch Err;
           error('HORACE:hdf_tools','read_component_headers, Can not open header %s, Err: %s',subgroup_name,Err.message);
     end
     header{i}=struct();
     header{i}=read_fields_list_attr(group_ID,field_names,header{i});
     %
     % it is no difference in C between row and column vector so this
     % information is lost after writing to hdf and has to be recovered. 
     header{i}.(field_names{is_column})=header{i}.(field_names{is_column})';         
     
     H5G.close(group_ID);
end

