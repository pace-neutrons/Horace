function volume = calc_bin_volume_(obj,nodes_info,varargin)
%CALC_BIN_VOLUME_ calculate the volume of a lattice cell defined by the
%cellarray of lattice axes or by the coordinates of the grid nodes
%
% The volume is either single value if all axes bins are the same or the
% 1D array of size of total number of bins in the lattice if some cell
% volumes differ, or array of size(nodes_info)-1 if grid node coordinates
% are provided as the input.
%

[is_axes,grid_size]= AxesBlockBase.process_bin_volume_inputs(obj,nodes_info,varargin{:});

if is_axes
    cell_sizes = cell(1,4);
    volume_is_array = false;
    for i=1:4
        ax = nodes_info{i};
        cell_sizes{i} = ax(2:end)-ax(1:end-1);
        if abs(min(cell_sizes{i}) - max(cell_sizes{i})) > eps('single')
            volume_is_array  = true;
        end
    end

    if volume_is_array
        volume = cell_sizes{1}(:)';
        for i=2:4
            volume = repmat(volume(:)',1,grid_size(i)-1).*...
                repelem(cell_sizes{i}(:)',numel(volume));
        end
    else
        vol = cellfun(@(x)x(1),cell_sizes);
        volume = prod(vol);
    end
else
    volume = calc_bin_volume(nodes_info,grid_size);
end
volume = volume*obj.get_volume_scale();
