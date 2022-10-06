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
[nodes,~,~,int_cell_volume] = ...
    obj.get_bin_nodes('-center',source_cube);

mult_coeff = int_cell_volume./base_cell_volume;

densities = zeros(numel(in_data),size(nodes,2));
for i = 1:numel(in_data)
    ref_ds = normalize_dataset(obj,in_data{i},mult_coeff,npoints_in_base);

    interp_ds = interpn(gridX,gridY,gridZ,gridE,ref_ds,...
        nodes(1,:),nodes(2,:),nodes(3,:),nodes(4,:), ...
        'linear',0);
    densities(i,:) = interp_ds;
end

function ref_ds = normalize_dataset(obj,in_data,base_cell_volume,base_size)
% normalize reference dataset
base_density = in_data./base_cell_volume;
% interpolate data into points on expanded  grid

is_pax = false(4,1);
is_pax(obj.pax)= true;

rep_rate = ones(1,4);
ranges  = cell(sum(is_pax,1));
exp_size = base_size;
for i=1:4
    if is_pax(i) % projection axes dimensions have halo        
        ranges{i} = 2:base_size(i)-1;
    else
    % intergated dimensions are replicated to have the same value in min/max
    % position       
        rep_rate(i) = 2;
        exp_size(i) = 1;
        ranges{i} = 1;
    end
end
% assign reference dataset to 
ref_ds  = zeros(exp_size);
ref_ds(ranges{:}) = base_density;

ref_ds = repmat(ref_ds,rep_rate);



