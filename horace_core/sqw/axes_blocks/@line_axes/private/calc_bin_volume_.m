function volume = calc_bin_volume_(obj,nodes_info,varargin)
%CALC_BIN_VOLUME_ calculate the volume of a lattice cell defined by the
%cellarray of grid axes or array of coordinates of the grid nodes.
%
% The volume is either single value if all axes bins are the same or the
% 1D array of size of total number of bins in the lattice if some cell
% volumes differ or prod(grid_size-1) array of volumes if nodes_info is
% array.
%
% Inputs:
% nodes_info   --
%       either:   4-element cellarray containing grid axes coordinates
%       or    :   3xN-elememts or 4xN-elements array of grid nodes
%                 produced by ndgrid function and combined into single
%                 array
% grid_size    -- if nodes_info is provided as array, 3 or 4 elements array
%                 containing sizes of the grid for the grid nodes in this
%                 array. Ignored if nodes_info contains axes.
% Output:
% volume       -- depending on input, single value or array of grid volumes
%                 measured in A^-3*mEv


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
% convert to A^-3*mEv
volume = volume*obj.get_volume_scale();
