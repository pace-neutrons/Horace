function x_val = parse_field_info_(field_name,x_axis_template,foi)
% parse dataset name and extract value, requested by
% x_axis_template

trial = textscan(field_name,x_axis_template);
if numel(trial)<foi || isempty(trial{foi})
    x_val = [];
    return ;
end
x_val = trial{foi};
