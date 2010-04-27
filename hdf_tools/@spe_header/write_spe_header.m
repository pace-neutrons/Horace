 function this=write_spe_header(this,sqw_data)
% function writes the auxiliary fields existing in swq_data and diefined by the 
% field this.field_names into recursive data sructure under the header
% this.HeaderDSName
%
% $Revision$ ($Date$)
%
if this.file_is_opened
        file_ID = this.sqw_file_ID;
        file_opened_initially=true;
else
        file_ID = open_or_create(fullfule(this.filepath,[this.filename,this.file_ext]));
        file_opened_initially=false;
end

% add nexus header to an spe file to recognise this file as a nexus file;
write_nexus(nexus_header(),file_ID,[this.filename,this.file_ext]);

% write fields
write_fields_list_attr(file_ID,this.HeaderDSName,this.spe_field_names,sqw_data);

if ~file_opened_initially
    H5F.close(file_ID);
end
      

