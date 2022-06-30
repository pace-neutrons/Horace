function data_column = extract_data_(data,x_axis,x_axis_template,foi)
% Extract data row from the structure, containing other structures,
% dependent on a some variable. The value of this variable is encoded in
% the structure field name

fn = fields(data);
data_column = NaN(size(x_axis));
for i=1:numel(fn)
    ds = data.(fn{i});
    x_val = parse_field_info_(fn{i},x_axis_template,foi);
    if ~isempty(x_val)
        pos = x_axis==x_val;
        data_column(pos) = ds.time_sec;
    end
end
