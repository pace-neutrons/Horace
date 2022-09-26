function ax = get_axes(obj)
% slice data_sqw_dnd object and extract its axes part
in = obj.to_struct();
in.serial_name = 'axes_block';
ax = axes_block.from_struct(in);