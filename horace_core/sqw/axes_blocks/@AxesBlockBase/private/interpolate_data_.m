function [s,e,npix] = interpolate_data_(targ_axes,nout,ref_axes,ref_proj,ref_data,targ_proj)
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


if ~targ_proj.do_3D_transformation
    error('HORACE:AxesBlockBase:not_implemented', ...
        '4D axes block transformation is not yet implemented');
end
% cross-assign the source and target projection transformations
%
%
[ref_nodes,density] = ref_axes.get_density(ref_data);
% cross-assign source->target and target->source projections
% as each other target projection to enable possible optimizations
% doing transformations in similar coordinate systems.
ref_proj.targ_proj = targ_proj;
targ_proj.targ_proj = ref_proj;
%ref_nodes = ref_proj.from_this_to_targ_coord(ref_nodes);

ref_grid_size = size(density{1});
ref_gridX = reshape(ref_nodes(1,:),ref_grid_size );
ref_gridY = reshape(ref_nodes(2,:),ref_grid_size );
ref_gridZ = reshape(ref_nodes(3,:),ref_grid_size );
ref_gridE = reshape(ref_nodes(4,:),ref_grid_size );

[ref_nodes,dE_nodes] = ref_axes.get_bin_nodes('-3D','-hull');
ref_nodes = ref_proj.transform_img_to_pix(ref_nodes);
range     = min_max(ref_nodes)';
dE = [min(dE_nodes);max(dE_nodes)];
range     = [range,dE];
char_size = (range(2,:)-range(1,:))./ref_axes.nbins_all_dims;
%
if ~isempty(targ_proj)

    nbins_all_dims = targ_axes.nbins_all_dims;
    range_cc       = targ_axes.get_targ_range(targ_proj,line_proj('type','aaa'),targ_axes.img_range);
    cut_range      = range_cc(2,:)-range_cc(1,:);
    targ_step      = cut_range ./nbins_all_dims;
    too_coarse     = targ_step>char_size/2;
    nbins_all_dims(too_coarse) = floor(2*cut_range(too_coarse)./char_size(too_coarse));
    targ_step  = cut_range./nbins_all_dims;

    test_size = cut_range(1,:)+nbins_all_dims.*targ_step;
    too_small   = abs(test_size-cut_range)<eps('single');
    nbins_all_dims(too_small) = nbins_all_dims(too_small)+1;

    [nodes,dE_nodes] = targ_axes.get_bin_nodes('-3D','-bin_centre',nbins_all_dims);
    % this are the interpolation nodes in source coordinate system
    inodes           = targ_proj.from_this_to_targ_coord(nodes);
    nbad3            = nbins_all_dims(1:3);
    %targ_cell_volume = ref_axes.calc_bin_volume({reshape(inodes(1,:),nbad3),reshape(inodes(2,:),nbad3),reshape(inodes(3,:),nbad3)});
    targ_cell_volume= ones(nbad3);

    if ~isempty(dE_nodes)
        inodes = [repmat(inodes,1,numel(dE_nodes));repelem(dE_nodes,size(inodes,2))];
        % substantially use fact that dE nodes are dirstributed regularly
        dE     = dE_nodes(2:end)-dE_nodes(1:end-1);
        dE     = paddata_horace(dE,numel(dE)+1);
        dE(end) = 0.5*dE(1);
        dE(1)   = dE(end);
        targ_cell_volume  = reshape(targ_cell_volume(:).*dE(:)',[nbad3,numel(dE)]);
    end
else % usually debug mode. Original grid coincides with interpolation grid
    [nodes,~,~,targ_cell_volume] = targ_axes.get_bin_nodes('-bin_centre');
    inodes = nodes;
    dE_nodes = [];
end

% do interpolation in source coodinate system
interp_ds = interpn(ref_gridX,ref_gridY,ref_gridZ,ref_gridE,density{1},...
    inodes(1,:),inodes(2,:),inodes(3,:),inodes(4,:), 'linear',0);

signal = interp_ds(:).*targ_cell_volume(:);

nsig = sum(signal); % total number of contributing pixels or
% whatever replaces them in tests is 0
if nsig == 0
    min_base = min(ref_nodes,[],2);
    max_base = max(ref_nodes,[],2);
    min_cut  = min(inodes,[],2);
    max_cut  = max(inodes,[],2);
    mess = format_warning(min_base,max_base,min_cut,max_cut);
    warning('HORACE:runtime_error', mess);
    s = zeros(targ_axes.dims_as_ssize);
    e = zeros(targ_axes.dims_as_ssize);
    npix =  zeros(targ_axes.dims_as_ssize);
    return;
end

%
if ~isempty(dE_nodes)
    nodes = [repmat(nodes,1,numel(dE_nodes));repelem(dE_nodes,size(nodes,2))];
end

[npix,s] = targ_axes.bin_pixels(nodes,[],[],[],{signal});
e = inf(size(s));


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
mess = sprintf([ '\n',...
    ' data range: Min = %s;%s  Max = [%g,%g,%g,%g]\n', ...
    ' cut range: Min = %s;%s  Max = [%g,%g,%g,%g]\n', ...
    ' Cut contains no data\n'], ...
    min_s_str,u_pad,max_base,min_c_str,l_pad,max_cut);

