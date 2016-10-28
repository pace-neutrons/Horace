function   [fn_start,fn_end,is_last] = extract_field_range(pos_fields,form_fields)
% function extracts first and last field in the structure pos_fields
% corrspongint to the structure form_fields
% The structures have to have special form, nameldy all field names in
% pos_fields structure should look like form_fields with '_pos_' suffix
% added to the end


fnf = fieldnames(form_fields);
fni = fieldnames(pos_fields);
f_f = [fnf{1},'_pos_'];
f_l = [fnf{end},'_pos_'];
%
field_ind = cellfun(@(x)(strcmp(x,f_l)||strcmp(x,f_f)),fni);

ind = find(field_ind);
if numel(ind) ~= 2
    error('DND_BINFILE_COMMON:invalid_argument',...
        'inconsistent fieldnames between position and format structures')
end
%
fn_start = fni{ind(1)};
if ind(2) == numel(fni) % last position is the position of the end of the methadata
    fn_end = fni{ind(2)};
    is_last = true;
else
    fn_end = fni{ind(2)+1};
    is_last = false;
end


