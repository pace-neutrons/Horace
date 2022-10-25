function varargout = interpolate_data_(obj,nout,ref_nodes,density, ...
    ref_grid_cell_size,proj)
% interpolate density data for signal, error and number of
% pixels provided as input density and defined on the references
% nodes onto the grid, defined by this block
%
% Inputs:
% nout      -- number of elements in cellarray of densities
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
    % this grid but to be smaller than the reference grid to have
    % at least one interpolation point within each reference cell
    do_expand = cell_ratio > 1;
    cell_ratio = round(cell_ratio);
    eq_one = cell_ratio == 1;
    shrunk_to_one = do_expand & eq_one;
    cell_ratio(shrunk_to_one) = 2;

    % ensure correct commensurate grid has been build
    com_cell_size= this_cell_size;
    min_npix=0; max_npix=1; count = 0;
    while(min_npix ~= max_npix && count<4)

        com_cell_size(do_expand) = this_cell_size(do_expand)./cell_ratio(do_expand);
        [nodes,~,~,int_cell_size] = obj.get_bin_nodes('-density_integr',com_cell_size);
        npix = obj.bin_pixels(nodes);

        min_npix=min(npix(:)); max_npix=max(npix(:)); count = count+1;
        cell_ratio(do_expand ) = cell_ratio(do_expand)+1;
    end
    if min_npix ~= max_npix
        warning('HORACE:runtime_error', ...
            ['Problem generating the interpolation grid commensurate with the cut grid.', ...
            ' The image artefacts will appear on the cut.', ...
            ' Contact the deveopers team to address the issue.'])
    end

    if ~isempty(proj)
        inodes = proj.from_this_to_targ_coord(nodes);
    else
        inodes = nodes;
    end
else % usually debug mode. Original grid coincides with interpolation grid
    [nodes,~,~,int_cell_size] = obj.get_bin_nodes('-density_integr');
    inodes = nodes;
end
int_cell_volume = prod(int_cell_size);

for i = 1:nout
    interp_ds = interpn(ref_gridX,ref_gridY,ref_gridZ,ref_gridE,density{i},...
        inodes(1,:),inodes(2,:),inodes(3,:),inodes(4,:), 'linear',0);

    varargout{i} = interp_ds.*int_cell_volume;
end
nsig = sum(varargout{nout}(:));
if nsig == 0
    min_base = min(ref_nodes,[],2);
    max_base = max(ref_nodes,[],2);
    min_cut  = min(inodes,[],2);
    max_cut  = max(inodes,[],2);
    mess = format_warning(min_base,max_base,min_cut,max_cut);
    warning('HORACE:runtime_error', mess);
end
%
%[npix,s,e,npix_interp] = bin_pixels(obj,coord_transf,varargin)
[~,varargout{1},varargout{2},varargout{3}] = obj.bin_pixels(nodes,[],[],[],varargout(1:nout));

%
function mess = format_warning(min_base,max_base,min_cut,max_cut)
min_s_str = sprintf('[%g,%g,%g,%g]',min_base);
min_c_str = sprintf('[%g,%g,%g,%g]',min_cut);
lmin = numel(min_s_str);
lmax = numel(min_c_str);
if lmin<lmax
    u_pad = repmat(' ',1,lmax-lmin);
    l_pad = '';
else
    u_pad = '';
    l_pad = repmat(' ',1,lmin-lmax);
end
mess = sprintf([ ...
    '\ndata range: Min = %s;%s  Max = [%g,%g,%g,%g]\n', ...
    ' cut range: Min = %s;%s  Max = [%g,%g,%g,%g]\n', ...
    ' Cut contains no data\n'], ...
    min_s_str,u_pad,max_base,min_c_str,l_pad,max_cut);

