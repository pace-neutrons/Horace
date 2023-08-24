function inputs = convert_old_struct_(~,inputs)
%
if isfield(inputs(1),'class_version_') && inputs(1).class_version_ == 1
    inputs = rmfield(inputs,'class_version_');
    % rename old fieldnames to new one
    cell_data = struct2cell(inputs);
    new_fld_names = {'pdf';'indx_to_save'};
    inputs = cell2struct(cell_data,new_fld_names);
end
