function varargout = interpolate_data_(targ_axes,nout,ref_axes,ref_proj,ref_data,targ_proj)
% interpolate density data for signal, error and number of
% pixels provided as input density and defined on the references
% nodes onto the grid, defined by this block
%
% Inputs:
% targ_ax   -- the axes_block object, providing the grid to interpolate
%              data on.
%
% nout      -- number of elements in cellarray of densities
%
% ref_axes
%           -- axes block -source grid, defining the lattice
%              where source data are defined on
% ref_proj
%           -- the projection, which defines the coordinate
%              system related to the ref_axes
%
% data      -- 1 to 3-elements cellarray containing arrays of data
%              to interpolate on the nodes of the input axes
%              block. In the most common case this is the
%              celarray of s,e,npix data, defined on source
%              axes block. source_axes.nbins_all_dims ==
%              size(data{i}) where
% targ_proj -- the projection object defining the transformation
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
% cross-assign the source and target projection transformations
%
%
[ref_nodes,density] = ref_axes.get_density(ref_data);
%n_ref_nodes = size(ref_nodes,2);

%
ref_grid_size = size(density{1});
ref_gridX = reshape(ref_nodes(1,:),ref_grid_size );
ref_gridY = reshape(ref_nodes(2,:),ref_grid_size );
ref_gridZ = reshape(ref_nodes(3,:),ref_grid_size );
ref_gridE = reshape(ref_nodes(4,:),ref_grid_size );

if ~isempty(targ_proj)
    % cross-assign projection to enable possible optimizations:
    ref_proj.targ_proj = targ_proj;
    targ_proj.targ_proj = ref_proj;

    % Identify how many interpolation nodes may belong to the original area
    [may_contrND_targ,may_contr_dE_targ]  = targ_proj.may_contribute(targ_axes, ...
        ref_proj,ref_axes);
    if targ_proj.do_3D_transformation
        n_ref_nodes = sum(may_contrND_targ)*sum(may_contr_dE_targ);
    else
        n_ref_nodes = sum(may_contrND_targ);
    end
    targ_contr_share = n_ref_nodes/prod(targ_axes.dims_as_ssize+1);
    [may_contrND,may_contr_dE]  = ref_proj.may_contribute(ref_axes, ...
        targ_proj,targ_axes);
    if ref_proj.do_3D_transformation
        n_ref_nodes = sum(may_contrND)*sum(may_contr_dE);
    else
        n_ref_nodes = sum(may_contrND);
    end


    if isempty(may_contrND) % the source and target grids do not have
        % intersection points
        res = zeros(targ_axes.dims_as_ssize);
        for i= 1:nout
            varargout{i} = res;
        end
        return;
    end
    % ensure that all cells which may contribute to the cut contain
    % at least one point of the interpolating grid. Build finer and finer
    % interpolation grid until this happens
    mult = 1;
    [all_accounted4,nodes,inodes,dE_nodes,targ_cell_volume] = bin_targ_on_source( ...
        ref_proj,ref_axes,targ_proj,targ_axes,mult,may_contrND,may_contr_dE);
    n_targ_nodes = size(inodes,2)*targ_contr_share;
    % rough estimate of the number of nodes increase after doubling node
    % multiplier
    dim_multiplier = 2^(ref_axes.dimensions()+1);

    mult = 2;
    while ~all_accounted4 && n_targ_nodes < dim_multiplier*n_ref_nodes % not fully reliable condition, as
        % e.g. for rectangular->spherical transformation hign-R cells may
        % be too big to fit one original rectangular cell, while plenty of
        % low-R cell fit a grid cell. Despite that due to oversampling, should
        % still be reasonable result with warning
        [all_accounted4,nodes,inodes,dE_nodes,targ_cell_volume] = bin_targ_on_source( ...
            ref_proj,ref_axes,targ_proj,targ_axes, ...
            mult,may_contrND,may_contr_dE);
        mult = mult*2;
        n_targ_nodes = size(inodes,2)*targ_contr_share;
    end
    if ~all_accounted4
        warning('HORACE:runtime_error', ...
            ['Problem generating the cut grid commensurate with the interpolation grid.\n', ...
            ' The interpolation artefacts may appear on the cut.\n', ...
            ' Use cut_sqw to be sure you results are right'])
    end
    if ~isempty(dE_nodes)
        inodes = [repmat(inodes,1,numel(dE_nodes));repelem(dE_nodes,size(inodes,2))];
    end

else % usually debug mode. Original grid coincides with interpolation grid
    [nodes,~,~,targ_cell_volume] = targ_axes.get_bin_nodes('-bin_centre');
    inodes = nodes;
end

for i = 1:nout
    interp_ds = interpn(ref_gridX,ref_gridY,ref_gridZ,ref_gridE,density{i},...
        inodes(1,:),inodes(2,:),inodes(3,:),inodes(4,:), 'linear',0);

    varargout{i} = interp_ds.*targ_cell_volume;
end
nsig = sum(varargout{nout}(:)); % total number of contributing pixels or
% whatever replaces them in tests is 0
if nsig == 0
    min_base = min(ref_nodes,[],2);
    max_base = max(ref_nodes,[],2);
    min_cut  = min(inodes,[],2);
    max_cut  = max(inodes,[],2);
    mess = format_warning(min_base,max_base,min_cut,max_cut);
    warning('HORACE:runtime_error', mess);
end
clear inodes;
if ~isempty(dE_nodes)
    nodes = [repmat(nodes,1,numel(dE_nodes));repelem(dE_nodes,size(nodes,2))];
end

%
%Pattern: [npix,s,e,npix_interp]           =        obj.bin_pixels(coord_transf,varargin)
[~,varargout{1},varargout{2},varargout{3}] = targ_axes.bin_pixels(nodes,[],[],[],varargout(1:nout));

function [all_accounted4,nodes,inodes,dE_nodes,targ_cell_volume] = bin_targ_on_source( ...
    ~,ref_axes,targ_proj,targ_ax,mult,may_contrND,may_contr_dE)
% Rebin target nodes on the source grid to verify that the target grid is
% fine enough to account for all source grid points
%
grid_mult = ones(1,4);
search_ax = targ_proj.projection_axes_coverage(ref_axes);
grid_mult(search_ax) = mult;
if targ_proj.do_3D_transformation
    [nodes,dE_nodes,~,targ_cell_volume] = targ_ax.get_bin_nodes('-3D','-bin_centre',grid_mult);
    source_edges = ref_axes.dE_nodes();
    ind = histcounts(dE_nodes,source_edges);
    dE_accounted4 = all(ind(may_contr_dE)>0);
else
    [nodes,~,~,targ_cell_volume] = targ_ax.get_bin_nodes('-bin_centre',grid_mult);
    dE_nodes       = [];
    dE_accounted4  = true;
end

inodes = targ_proj.from_this_to_targ_coord(nodes);
npix = ref_axes.bin_pixels(inodes);
all_accounted4 = all(npix(may_contrND)>0) & dE_accounted4;

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

