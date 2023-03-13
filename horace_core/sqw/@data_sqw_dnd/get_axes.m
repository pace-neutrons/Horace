function ax = get_axes(obj)
% slice data_sqw_dnd object and extract its axes part
in = obj.to_struct();
in.serial_name = 'ortho_axes';
ax = ortho_axes.from_struct(in);