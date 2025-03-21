function inputs = modify_old_structure_(inputs)
% Modify old structure, possibly available in dnd object to
% be acceptable by modern DnD object loader
if isfield(inputs,'version') && inputs.version<4
    if isfield(inputs,'proj')
        inputs.proj = serializable.loadobj(inputs.proj);
    else
        inputs.proj = line_proj.get_from_old_data(inputs);
        if isfield(inputs,'uoffset')
            inputs = rmfield(inputs,'uoffset');
        end
    end
    if isfield(inputs,'axes')
        inputs.axes = serializable.loadobj(inputs.axes);
    else
        inputs.axes = line_axes.get_from_old_data(inputs);
    end
else
    if isfield(inputs,'data_')
        inputs = inputs.data_;
    end
    if isfield(inputs,'pax') && isfield(inputs,'iax')
        inputs.axes = line_axes.get_from_old_data(inputs);
        if isfield(inputs,'img_db_range')
            inputs = rmfield(inputs,'img_db_range');
        end
        inputs.proj = line_proj.get_from_old_data(inputs);
        if isfield(inputs,'uoffset')
            inputs = rmfield(inputs,'uoffset');
        end
    end
    if isfield(inputs,'pix_')
        inputs.pix = inputs.pix_;
    end
end
