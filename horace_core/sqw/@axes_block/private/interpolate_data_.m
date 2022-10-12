function varargout = interpolate_data_(obj,nout,ref_nodes,density,grid_cell_size)
% interpolate density data for signal, error and number of
% pixels provided as input density and defined on the references
% nodes onto the grid, defined by this block
%
% Inputs:
% nout      -- number of elements in cellarry of densities
% ref_nodes -- 4D array of the nodes of the reference lattice,
%              produced by get_density routine of the reference
%              axes block and projected into coordinate system of this axes
%              block
% density   -- 3-elemens cellarray containing arrays of
%              signal, error and npix densities,
%              produced by get_density routine of the reference
%              axes block.
% grid_cell_size
%           -- 4D array of the scales of the reference lattice,
%              projected onto this lattice.
% Returns:
% s,e,npix  -- interpolated arrays of signal, error and number
%              of pixels calculated in the centers of the
%              cells of this lattice.

for i= 1:nargout
    varargout{i} = [];
end
%
ref_grid_size = size(density{1});
ref_gridX = reshape(ref_nodes(1,:),ref_grid_size );
ref_gridY = reshape(ref_nodes(2,:),ref_grid_size );
ref_gridZ = reshape(ref_nodes(3,:),ref_grid_size );
ref_gridE = reshape(ref_nodes(4,:),ref_grid_size );

if ~isempty(grid_cell_size)
    [~,this_cell_size] = obj.get_axes_scales();
    
    cell_ratio = this_cell_size./grid_cell_size;
    % decrease the interpolation cell size to be commensurate with 
    % this grid but to be smaller then the reference grid to have
    % at least one interpolation point within a reference cell
    do_expand = cell_ratio > 1;
    this_cell_size(do_expand) = this_cell_size(do_expand)./ceil(cell_ratio(do_expand));
    [nodes,~,~,int_cell_volume] = obj.get_bin_nodes('-density_integr',this_cell_size);
else
    [nodes,~,~,int_cell_volume] = obj.get_bin_nodes('-density_integr');
end


for i = 1:nout
    interp_ds = interpn(ref_gridX,ref_gridY,ref_gridZ,ref_gridE,density{i},...
        nodes(1,:),nodes(2,:),nodes(3,:),nodes(4,:), 'linear',0);
    varargout{i} = interp_ds.*int_cell_volume;
end
%
%[npix,s,e,npix_interp] = bin_pixels(obj,coord_transf,varargin)
[npix,varargout{1},varargout{2},varargout{3}] = obj.bin_pixels(nodes,[],[],[],varargout(1:nout));
% for i=1:nout
%     varargout{i} = varargout{i}./npix;
% end