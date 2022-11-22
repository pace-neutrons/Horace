function inputs = convert_old_struct_(~,inputs)
%
if isfield(inputs(1),'class_version_') && inputs(1).class_version_ == 1
    % remove _ from version 1 old fields
    inputs = rmfield(inputs,'class_version_');    
    old_fld_names = fieldnames(inputs(1));
    % use the fact that the old field names are the new field
    % names with _ attached at the end
    new_fld_names = cellfun(@(x)(x(1:end-1)),old_fld_names,...
        'UniformOutput',false);
    cell_data = struct2cell(inputs);
    inputs = cell2struct(cell_data,new_fld_names);
end
