function varargout = interpolate_data_(obj,nout,ref_nodes,density, ...
    ref_grid_cell_size,proj)
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
% density   -- 3-elements cellarray containing arrays of
%              signal, error and npix densities,
%              produced by get_density routine of the reference
%              axes block.
% Optional:
% ref_grid_cell_size
%           -- 4D array of the scales of the reference lattice
%              if missing or empty, assume ref_nodes have the same
%              cell sizes as these nodes
% proj      -- the projection object defining the transformation
%              from this coordinate system to the system,
%              where the reference nodes are defined
%              If missing or empty, assume that this coordinate
%              system and reference coordinate system are the
%              same
% Returns:
% s,e,npix  -- interpolated arrays of signal, error and number
%              of pixels calculated in the centres of the
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

if ~isempty(ref_grid_cell_size)
    [char_cube,this_cell_size] = obj.get_axes_scales();
    if ~isempty(proj)
        char_cube = proj.from_this_to_targ_coord(char_cube);
        trans_cell_size = max(char_cube,[],2)-min(char_cube,[],2);
    else
        trans_cell_size  = this_cell_size;
    end

    cell_ratio =  trans_cell_size./ref_grid_cell_size;
    % decrease the interpolation cell size to be commensurate with
    % this grid but to be smaller then the reference grid to have
    % at least one interpolation point within each reference cell
    do_expand = cell_ratio > 1;
    this_cell_size(do_expand) = this_cell_size(do_expand)./ceil(cell_ratio(do_expand));
    [nodes,~,~,int_cell_size] = obj.get_bin_nodes('-density_integr',this_cell_size);
    if ~isempty(proj)
        inodes = proj.from_this_to_targ_coord(nodes);
    else
        inodes = nodes;
    end
else % usually debug mode. Original grid coincide with interpolation grid
    [nodes,~,~,int_cell_size] = obj.get_bin_nodes('-density_integr');
    inodes = nodes;
end
int_cell_volume = prod(int_cell_size);


for i = 1:nout
    interp_ds = interpn(ref_gridX,ref_gridY,ref_gridZ,ref_gridE,density{i},...
        inodes(1,:),inodes(2,:),inodes(3,:),inodes(4,:), 'linear',0);
    varargout{i} = interp_ds.*int_cell_volume;
end
%
%[npix,s,e,npix_interp] = bin_pixels(obj,coord_transf,varargin)
[~,varargout{1},varargout{2},varargout{3}] = obj.bin_pixels(nodes,[],[],[],varargout(1:nout));
%
