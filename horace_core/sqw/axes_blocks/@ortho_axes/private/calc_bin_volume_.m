function volume = calc_bin_volume_(obj,ax_in_cell)
%CALC_BIN_VOLUME_ calculate the volume of a lattice cell defined by the
%cellarray of lattice axes.
%
% The volume is either single value if all axes bins are the same or the
% 1D array of size of total number of bins in the lattice if some cell
% volumes differ.
%
if ~iscell(ax_in_cell) || numel(ax_in_cell) ~=4
    error('HORACE:AxesBlockBase:invalid_argument', ...
        'Input for calc_bin_volume function should be cellarray containing 4 axis. It is %s', ...
        disp2str(ax_in_cell));
end

grid_sizes = cell(1,4);
volume_is_array = false;
for i=1:4
    ax = ax_in_cell{i};
    grid_sizes{i} = ax(2:end)-ax(1:end-1);
    if abs(min(grid_sizes{i}) - max(grid_sizes{i})) > eps('single')
        volume_is_array  = true;
    end
end

if volume_is_array
    volume = grid_sizes{1}(:)';
    for i=2:4
        volume = repmat(volume(:)',1,numel(grid_sizes{i})).*...
            repelem(grid_sizes{i}(:)',numel(volume));
    end
else
    vol = cellfun(@(x)x(1),grid_sizes);
    volume = prod(vol);
end
if obj.nonorthogonal
    cell_vol = cross(obj.unit_cell(1:3,1),obj.unit_cell(1:3,2))'*obj.unit_cell(1:3,3);
    volume  = volume.*cell_vol;
end