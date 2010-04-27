function [this,new_structure]=parse_header_arguments(this,modificators)
% internal method for spe_header
%
% function analyses the modificators_structure 
% and modifies some default properties of the  object
% usage:
% this=parse_header_arguments(this,modificators)
%
% modificators -- the structure with the properties which should be
%                 recognized (will be ignored otherwise)
%
% possible fields are:
%
% fields_to_mod -- list of the fields to add or to remove from the default
%                  fields in the header
% new_extension -- new extension for the hdf file, which we are creating
% 
% fail_if_new_file -- do not create new hdf file if one does not exist and
%                     fail if old file is not present
% 
% sqwn_header_structure - the value of this field is the sqwn
%                     structure with its field. These fields replace fields
%                     of default spe structure;
%
% $Revision$ ($Date$)
%
new_structure=[];
% modify the field list if necessary to write new fields into the file
if isfield(modificators,'fields_to_mod')    % cell array
    this.spe_field_names=modify_field_names_list(this.spe_field_names,modificators.fields_to_mod);
end
% modify file extension if necessary
if isfield(modificators,'new_extension')  % string -- file extention
      if ~ischar(modificators.new_extension)              
          msg = ['spe_header=> new_extension field, if present, has to be a string defining the filename extention',...
                 ' old extention: ',this.file_ext,' left unchanged'];
          warning('HORACE:hdf_tools',msg);
      end

     this.file_ext = strtrim(modificators.new_extension);
     if this.file_ext(1) ~= '.'
           this.file_ext = ['.',this.file_ext];
     end
end

if isfield(modificators,'fail_if_new_file') % boolean
   this.fail_if_new_file=modificators.fail_if_new_file;   
end
% if this field is present, the header will write absolutely new structure;
if isfield(modificators,'sqwn_header_structure') % structure;
    new_structure = modificators.sqwn_header_structure;
    this.spe_field_names=fieldnames(new_structure);
end



