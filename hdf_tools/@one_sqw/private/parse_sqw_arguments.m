function this=parse_sqw_arguments(this,modificators_structure)
% internal method for spe_header
%
% function analyses the modificators_structure 
% and modifies some default values of the  object
%
% $Revision$ ($Date$)
%

% modify the field list if necessary to write new fields into the file
if isfield(modificators_structure,'fields_to_mod')    
   this.spe_field_names=modify_field_names_list(this.spe_field_names,...
                                                modificators_structure.fields_to_mod);
end
% modify file extension if necessary
if isfield(modificators_structure,'new_extension')
      if ~ischar(modificators_structure.new_extension)              
          msg = ['spe_header=> third parameter, if present, has to be a string defining the filename extention',...
                 ' old extention: ',this.file_ext,' left unchanged'];
          warning('HORACE:hdf_tools',msg);
      end

     this.file_ext = strtrim(modificators_structure.new_extension);
     if this.file_ext(1) ~= '.'
           this.file_ext = ['.',this.file_ext];
     end
end



