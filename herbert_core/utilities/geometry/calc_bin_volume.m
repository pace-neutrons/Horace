function volume = calc_bin_volume(coordinates,grid_size)
%CALC_BIN_VOLUME function takes coordinates of grid nodes in 1-4dimensions
% coordinates lattice and finds bin volumes of the grid cells
% in Cartesian coordinate system.
% 
% 
% Different coordinate system would overload this method using get_gridcell_ind
% function and appropriate cell volume formulas.
%
% Inputs:
% coordinates  -- [ND,Npoints] array (ND can be from 1 to 4) of coodriates
%                 of the bin nodes of a grid. The coordinates were produced
%                 by ndgrid function and then combined into [NX,Npoints]
%                 array.
% grid_size    -- ND-elements array (number of elements equal to number
%                 of rows in coordinates array) describing ND-dimensional
%                 size and shape of the grid.
% Returns:
% volume       -- array of volumes of the grid cells, described by the
%                 input coordinates


[idx,n_dims] = get_gridcell_ind(grid_size);

cell_vec = cell(n_dims,1);
for i=1:n_dims
    cell_vec{i} = coordinates(:,idx{i+1})-coordinates(:,idx{1});
end
switch(n_dims)
    case(1)
        volume = abs(cell_vec{1});
    case(2)
        i=1:size(cell_vec{1},2);
        volume = arrayfun(@(i)abs(det([cell_vec{1}(:,i),cell_vec{2}(:,i)])),i);
    case(3)
        i=1:size(cell_vec{1},2);
        volume = arrayfun(@(i)abs(det([cell_vec{1}(:,i),cell_vec{2}(:,i),cell_vec{3}(:,i)])),i);
    case(4)
        i=1:size(cell_vec{1},2);
        volume = arrayfun(@(i)abs(det([cell_vec{1}(:,i),cell_vec{2}(:,i),cell_vec{3}(:,i),cell_vec{4}(:,i)])),i);
    otherwise
        error('HERBERT:geometry:invalid_argument', ...
            ['only 1 to 4 dimensional coordinate systems are currently supported.\n' ...
            'Got input interpreted as %g dimensions'],n_dims);
end
