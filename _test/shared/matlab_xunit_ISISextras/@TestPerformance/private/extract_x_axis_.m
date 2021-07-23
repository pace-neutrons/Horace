function x_ax = extract_x_axis_(data,x_axis_template,foi)
%  Scan dataset field names for variable, defined by x_axis_template or
%  extract the variable directrly from x_val field of the datasets if such
%  field exist
fn = fields(data);
x_ax_map  = containers.Map();
for i=1:numel(fn)
    x_val = parse_field_info_(fn{i},x_axis_template,foi);
    if ~isempty(x_val)
        x_ax_map(fn{i}) = x_val;
    end
end
val = x_ax_map.values;
x_ax = [val{:}];
x_ax = sort(x_ax);
