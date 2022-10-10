function [int_grid,densities] = calculate_density_(obj,in_data)
% Convert input datasets into the density data, defined on
% centerpoints of the axes_block grid.


[nodes,~,npoints_in_base,base_cell_volume] = ...
    obj.get_bin_nodes('-interp','-halo');
gridX = reshape(nodes(1,:),npoints_in_base);
gridY = reshape(nodes(2,:),npoints_in_base);
gridZ = reshape(nodes(3,:),npoints_in_base);
gridE = reshape(nodes(4,:),npoints_in_base);

int_grid = {gridX,gridY,gridZ,gridE};

[ref_nodes,~,n_ref_points] = obj.get_bin_nodes('-interp');
gridX = reshape(ref_nodes(1,:),n_ref_points);
gridY = reshape(ref_nodes(2,:),n_ref_points);
gridZ = reshape(ref_nodes(3,:),n_ref_points);
gridE = reshape(ref_nodes(4,:),n_ref_points);


% provide the coefficient for the future integration over interpolated grid
% in the form int(grid,a,b) = 0.5*grid_step*sum(signal_i,for a<= i <b);
densities = cell(numel(in_data),1);

for i = 1:numel(in_data)
    densities{i} = normalize_dataset(obj,in_data{i},base_cell_volume,npoints_in_base);
    edges = isnan(densities{i});
    % for integrated datasets the method generates additional points
    % contributing to integral. Account for them
    if any(edges(:))
        ref_ds = normalize_extra_dataset(obj,in_data{i},base_cell_volume,n_ref_points);

        % reasonable operation would be linear extrapolation on half-cell
        % out of range but no ready interpolator is available for this
        % function in Matlab
        interp_dss = interpn(gridX,gridY,gridZ,gridE,ref_ds,...
            nodes(1,edges(:)),nodes(2,edges(:)),nodes(3,edges(:)),nodes(4,edges(:)), 'spline');
        densities{i}(edges) = interp_dss(:); % multiply edge values by half accounting
        %                                          to half volume at edges
        %                                          in integration formulas
        out_range = densities{i} < 0;
        if any(out_range)
            densities{i}(out_range) = 0;
        end
    end

end
function ref_ds = normalize_extra_dataset(obj,in_data,cell_volume,n_ref_points)
% interpolate data into points on expanded  grid
is_pax = false(1,4);
is_pax(obj.pax) = true;

ref_ds = in_data./cell_volume;

rep_rate = ones(1,4);
rep_rate(~is_pax) = 2;
shape  = n_ref_points;
shape(~is_pax) = 1;
ref_ds= reshape(ref_ds,shape);
ref_ds = repmat(ref_ds,rep_rate);


function ref_ds = normalize_dataset(obj,in_data,cell_volume,base_size_and_shape)
%
% interpolate data into points on expanded  grid
is_pax = false(1,4);
is_pax(obj.pax) = true;
% grid is expanded +one index from both sides of projection axis dimensins
ranges = arrayfun(@real_data_range,is_pax,obj.nbins_all_dims, ...
    'UniformOutput',false);
expanded_size =base_size_and_shape;
expanded_size(~is_pax) = 1;
ref_ds  = nan(expanded_size);
if ~all(is_pax) % there are integrated dimesions collapsed
    % 1D reference dataset have to be arranged in columns
    ref_ds = reshape(ref_ds,expanded_size);
end
% normalize reference dataset and assign into the target dataset
% leaving expanded edges as NaN
ref_ds(ranges{:}) = in_data./cell_volume;
%
% intergated dimensions are replicated to have the same value in min/max
% position to allow interpolation
rep_rate = ones(1,4);
rep_rate(~is_pax) = 2;
ref_ds = repmat(ref_ds,rep_rate);


function range = real_data_range(is_px,max_size)
if is_px
    range = [2:max_size+1];
else
    range = 1;
end
