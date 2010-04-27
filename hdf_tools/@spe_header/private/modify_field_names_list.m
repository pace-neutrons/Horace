function modified_fields=modify_field_names_list(old_fields,new_fields)
% function modifies cellarray of old_fields deleting the duplicates, which
% present in the new_fields and returning the list of the fields which are
% unique for in both old_fields,new_fields as the resulting array
% of modified_fields
%
% $Revision$ ($Date$)
%

old_fields_2keep=~ismember(old_fields,new_fields);
new_fields_2keep=~ismember(new_fields,old_fields);

old_fields_m = old_fields(old_fields_2keep);
new_fields_m = new_fields(new_fields_2keep);

modified_fields=[old_fields_m,new_fields_m];

