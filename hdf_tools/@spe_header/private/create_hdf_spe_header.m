function this=create_hdf_spe_header(this,sqw_data)
% function creates hdf5 dataset for sqw file
% copy the header data

% this has to be replaced by the function which works with proper fields
file_name=full_file_name(this);

if this.delete_existing_file
    if exist(file_name,'file')
             delete(file_name);
    end
else % *** > if file is not deleted, measure has to be taken to find the data header,
     %       open it and write the data there instead of the new header
end
% open file and prepare the place for the datasets
if ~this.file_is_opened
    this.sqw_file_ID    = open_or_create(file_name);    
    this.file_is_opened = true;
end
%if ~this.new_file_created % file is old
%    if exist(this.sqw_file_ID,this.HeaderDSName)
%            this.HeaderDSName = [this.HeaderDSName,'_',num2str(this.nInstance)];
%    end
%end

% list fields of the input structure and exclude fields that shoul not be
% there.
this.spe_field_names = fieldnames(sqw_data);
leave_fields       = ~ismember(this.spe_field_names,this.non_spe_field_names);
this.spe_field_names = this.spe_field_names(leave_fields);

% add the fields from this header to the structure to write;
fields_present = ismember(this.spe_field_names,this.this_field_names);
fields_in_spe   = this.spe_field_names(fields_present);
fields_absent  = ~ismember(this.this_field_names,this.spe_field_names);
fields_ni_spe  = this.this_field_names(fields_absent);
for i=1:numel(fields_in_spe)
    sqw_data.(fields_in_spe{i})=this.(fields_in_spe{i});
end
% add fields from this structure to the target structure to write;
for i=1:numel(fields_ni_spe)
    sqw_data.(fields_ni_spe{i})=this.(fields_ni_spe{i});    
end
this.spe_field_names = {this.spe_field_names{:},fields_ni_spe{:}};
%
% finaly, write the header;
this=write_spe_header(this,sqw_data);

