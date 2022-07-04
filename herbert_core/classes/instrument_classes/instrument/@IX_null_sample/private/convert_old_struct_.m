function inputs = convert_old_struct_(~,inputs)
%
if isfield(inputs(1),'class_version_') && inputs(1).class_version_ == 1
    inputs = rmfield(inputs,'class_version_');
    old_fld_names = fieldnames(inputs(1));
    % use the fact that the old field names are the new field
    % names with _ attached at the end
    new_fld_names = cellfun(@(x)(x(1:end-1)),old_fld_names,...
        'UniformOutput',false);
    cell_data = struct2cell(inputs);
    inputs = cell2struct(cell_data,new_fld_names);
elseif isfield(inputs(1),'name_') % old structure with private names
    % and without any versions
    old_fld_names = fieldnames(inputs(1));
    % use private function which traling _ from field names
    new_fld_names = cellfun(@remove_back_,old_fld_names,...
        'UniformOutput',false);
    struct_cell = struct2cell(inputs);
    inputs = cell2struct(struct_cell,new_fld_names);
end

function x = remove_back_(x)
% private function used by from_old_struct method of
% apperture to convert one kind of old fields into new
% fields
if x(end)=='_'
    x = x(1:end-1);
end

