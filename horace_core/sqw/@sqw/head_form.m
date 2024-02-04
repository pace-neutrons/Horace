function form_fields = head_form(sqw_only,keep_data_arrays)
% Returns list of fields, which need to be filled by
% head function
%
%
form_fields = {'nfiles','npixels','data_range','creation_date'};
sqw_only = exist('sqw_only', 'var') && sqw_only;
keep_data_arrays = exist('keep_data_arrays', 'var') && keep_data_arrays;

if sqw_only
    return
end

[dnd_fields,data_fields] = DnDBase.head_form(false);
if keep_data_arrays
    form_fields   = [dnd_fields(1:end-1)';form_fields(:);data_fields(:)];
else
    form_fields   = [dnd_fields(1:end-1)';form_fields(:)];
end
