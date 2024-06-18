function  [may_contributeND,may_contribute_dE] = may_contribute_(source_proj,...
    source_axes_block,targ_proj,targ_axes_block)
% Return the indexes of cells, which may contain the nodes,
% belonging to the target axes block by transforming the source
% coordinate system (SCS) into target coordinate system (TCS)
% and interpolating signal on SCS nodes assuming target coordinate system
% area contains unit signal and signal on SCS is interpolated from unary
% values on TCS and zero values outside of TCS.
%

% Assuming 3D case. 4D case would may be expanded later
if ~source_proj.do_3D_transformation
    error('HPRACE:AxesBlockBase:not_implemented', ...
        '4D grit overlapping is not yet implemented');
end

% build grid with points at bin edges for the target grid and bin centres
% for reference grid

dE_range_requested = targ_axes_block.img_range(:,4)';
dE_range_source    = source_axes_block.img_range(:,4)';
if any(source_axes_block.iax == 4)
    dE_edges = dE_range_source;
else
    dE_edges = linspace(dE_range_source(1),dE_range_source(2),source_axes_block.nbins_all_dims(4)+1);
end
[any_inside,may_contribute_dE] = AxesBlockBase.bins_in_1Drange(dE_edges,dE_range_requested);
if ~any_inside
    may_contributeND= [];
    return;
end
[source_grid,~,nbs]  = source_axes_block.get_bin_nodes('-bin_centre','-3D');
% convert the coordinates of the bin centres of the reference grid into
% the coordinate system of the target grid.
conv_grid = source_proj.transform_img_to_pix(source_grid);

% define unit signal on the edges of the target grid and zeros at "halo"
% points surrounding the target grid
char_sizes = source_axes_block.get_char_size(conv_grid,nbs);
[targ_nodes,targ_grid_present] = targ_axes_block.get_interp_nodes(targ_proj,char_sizes(1:3));


% find the presence of the reference grid centres within the target grid
% cells. If reference grid is present its signal is higher then 0

%F = scatteredInterpolant(targ_nodes(1,:)',targ_nodes(2,:)',targ_nodes(3,:)',targ_grid_present(:)');
%interp_ds = F(conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)', 'linear',0);
interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},targ_grid_present,...
    conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)', 'linear',0);

may_contributeND = interp_ds(:)>eps(single(1));

