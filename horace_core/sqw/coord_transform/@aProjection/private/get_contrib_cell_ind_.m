function  contrib_ind = get_contrib_cell_ind_(source_proj,...
    cur_axes_block,targ_proj,targ_axes_block)
% Return the indexes of cells, which may contain the nodes,
% belonging to the target axes block by
%
% Transforming the target coordinate system into source coordinate system
% and binning TCS nodes into source coodrinate system bins.
%
%

if isempty(targ_proj)
    targ_proj = source_proj.targ_proj;
end
%
% build bin edges for the target grid and bin centers for reference grid
if source_proj.do_3D_transformation_
    [targ_nodes,dEnodes] = targ_axes_block.get_bin_nodes('-3D','-ngrid');
    [ch_grid,baseEdges]  = cur_axes_block.get_bin_nodes('-density_integr','-3D','-halo');
    nodes_near = interp1(dEnodes,ones(size(dEnodes)),baseEdges,'linear',0);
    may_contribure = nodes_near>0;
    if ~any(may_contribure)
        contrib_ind = [];
        return;
    end
else
    targ_nodes = targ_axes_block.get_bin_nodes('-ngrid');
    ch_grid = cur_axes_block.get_bin_nodes('-density_integr','-halo');
end
nodes_present = ones(size(targ_nodes{1}));
% convert the coordinates of the bin centers of the reference grid into 
% the coordinate system of the target grid.
conv_grid = source_proj.from_this_to_targ_coord(ch_grid);

% find the presence of the reference grid centers within the target grid
% cells. 
if source_proj.do_3D_transformation_
    interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},nodes_present,...
        conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)', 'linear',0);

    contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
        interp_ds(:)>0,may_contribure);
else
    interp_ds = interpn(targ_nodes{1},targ_nodes{2},targ_nodes{3},targ_nodes{4},nodes_present,...
        conv_grid(1,:)',conv_grid(2,:)',conv_grid(3,:)',conv_grid(4,:)', 'linear',0);
    contrib_ind = find(interp_ds > 0);
end
