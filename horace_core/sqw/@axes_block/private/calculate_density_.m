function [nodes,densities] = calculate_density_(obj,in_data)
% Convert input datasets into the density data, defined on
% centerpoints of the axes_block grid.


[nodes,~,npoints_in_base,base_cell_volume] = ...
    obj.get_bin_nodes('-interp');
gridX = reshape(nodes(1,:),npoints_in_base);
gridY = reshape(nodes(2,:),npoints_in_base);
gridZ = reshape(nodes(3,:),npoints_in_base);
gridE = reshape(nodes(4,:),npoints_in_base);

% build twice as dense grid as the dataset is defined on to avoid round-off
% errors in the future integration over density
source_cube = 0.5*obj.get_axes_scales();
nodes = ...
    obj.get_bin_nodes('-interp',source_cube);


densities = zeros(numel(in_data),size(nodes,2));

for i = 1:numel(in_data)
    ref_ds = normalize_dataset(in_data{i},base_cell_volume,npoints_in_base);

    interp_ds = interpn(gridX,gridY,gridZ,gridE,ref_ds,...
        nodes(1,:),nodes(2,:),nodes(3,:),nodes(4,:), ...
        'linear',0);
    densities(i,:) = interp_ds;
end

function ref_ds = normalize_dataset(in_data,base_cell_volume,ds_size)
% normalize reference dataset
base_density = in_data./base_cell_volume;
% interpolate data into points on expanded  grid
ref_ds = zeros(ds_size);
%ranges = arrayfun(@as_range,ds_size,'UniformOutput',false);
ref_ds(2:end-1,2:end-1,2:end-1,2:end-1) = base_density;

function range = as_range(nbins)
if nbins == 1
    range = 1;
else
    range = 2:nbins-1;
end

