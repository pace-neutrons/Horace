function [data,define_axis_caption] = copy_data_from_structure(data,sqw_data_structure)
% method copies data from structure to internal class structure
%
% The structure should fields with names, correspondent to class names.
% the fiels with names absent in class will be rejected 
% if structure contains fields with data not appropriate for the class,
% the verification procedure will flag them later.

if isfield(sqw_data_structure,'axis_caption') && ~isempty(sqw_data_structure.axis_caption)
    define_axis_caption = false;
else
    define_axis_caption = true;
end
fields = fieldnames(sqw_data_structure);
for i=1:numel(fields)
    data.(fields{i}) = sqw_data_structure.(fields{i});
end

