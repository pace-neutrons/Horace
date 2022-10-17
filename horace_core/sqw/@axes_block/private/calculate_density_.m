function [dens_nodes,densities,base_cell_size] = calculate_density_(obj,in_data)
% Convert input datasets defined on centre-points of the axes_block grid into
% the density data, defined on edges of the axes_block grid.
%
% Inputs:
% in_data -- cellarray of input datasets to calculate density
%             from.
%             The size and dimensions of the datasets should
%             be equal to the dimensions of the axes block
%             returned by data_nbins property, i.e.:
%             all(size(dataset{i}) == obj.data_nbins;
%             datasets contain bin values.
% Returns:
% dens_nodes
%          -- 2D [4,nAxesEdgesPoints] array of axes point positions
%              where the density is defined
% densities
%          -- cellarray of density points calculated in the
%             density points positions.
%             Number of cells in the output array is equal to
%             the number of input datasets



% build data grid
[data_nodes,~,npoints_in_base,base_cell_size] = ...
    obj.get_bin_nodes('-data_to_density');
gridCX = reshape(data_nodes(1,:),npoints_in_base);
gridCY = reshape(data_nodes(2,:),npoints_in_base);
gridCZ = reshape(data_nodes(3,:),npoints_in_base);
gridCE = reshape(data_nodes(4,:),npoints_in_base);
%

% build density grid
base_cell_volume = prod(base_cell_size);

base_cell_size(obj.pax) = base_cell_size(obj.pax)./2;
[dens_nodes,~,n_ref_points] = obj.get_bin_nodes(base_cell_size);

% provide the coefficient for the future integration over interpolated grid
% in the form int(grid,a,b) = 0.5*grid_step*sum(signal_i,for a<= i <b);
densities = cell(numel(in_data),1);

for i = 1:numel(in_data)
    ref_ds  = convert_data_to_density(obj,in_data{i},base_cell_volume,npoints_in_base);
    densities{i} = interpn(gridCX,gridCY,gridCZ,gridCE,ref_ds,...
        dens_nodes(1,:),dens_nodes(2,:),dens_nodes(3,:),dens_nodes(4,:),'linear');

    edges = isnan(densities{i});
    % for integrated datasets the method generates additional points
    % contributing to integral. How to account for them?
    if any(edges(:))
        % reasonable operation would be linear extrapolation on half-cell
        % out of range using nearest divided by two to conserve integral
        % over the boundary cells.

        gint = griddedInterpolant(gridCX,gridCY,gridCZ,gridCE,ref_ds,'linear','nearest');
        interp_dss = gint(dens_nodes(1,edges(:)),dens_nodes(2,edges(:)),dens_nodes(3,edges(:)),dens_nodes(4,edges(:)));

        densities{i}(edges) = interp_dss(:); % if integrating, multiply edge
        %                                     values by half accounting
        %                                     to half volume at edges
        %                                     in the integration formulas
        % without this, integral over edges may cause additional values on
        % edges
        % make density array shape equal to the grid shape
        densities{i} = reshape(densities{i},n_ref_points);
    end

end
%




function ref_ds = convert_data_to_density(obj,in_data,cell_volume,n_ref_points)
% convert data into density and  assign density
% points to the edges of integrated dimensions assuming bin centre of
% projected directions
is_pax = false(1,4);
is_pax(obj.pax) = true;

ref_ds = in_data./cell_volume;

rep_rate = ones(1,4);
rep_rate(~is_pax) = 2;
shape  = n_ref_points;
shape(~is_pax) = 1;
ref_ds= reshape(ref_ds,shape);
ref_ds = repmat(ref_ds,rep_rate);

