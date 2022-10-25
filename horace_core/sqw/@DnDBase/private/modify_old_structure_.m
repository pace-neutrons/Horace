function inputs = modify_old_structure_(inputs)
% Modify old structure, possibly available in dnd object to 
% be acceptable by modern DnD object loader
if isfield(inputs,'version') && inputs.version<4
    inputs.proj = ortho_proj.get_from_old_data(inputs);
    inputs.axes = axes_block.get_from_old_data(inputs);
else
    if isfield(inputs,'data_')
        inputs = inputs.data_;
    end
    if isfield(inputs,'pax') && isfield(inputs,'iax')
        inputs.axes = axes_block.get_from_old_data(inputs);
        if isfield(inputs,'img_db_range')
            inputs = rmfield(inputs,'img_db_range');
        end
        inputs.proj = ortho_proj.get_from_old_data(inputs);
    end
    if isfield(inputs,'uoffset')
        if isfield(inputs,'proj')
            inputs.proj.offset = inputs.uoffset;
        else
            inputs.offset = inputs.uoffset;
        end
        inputs = rmfield(inputs,'uoffset');
    end
end
