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
% Get the hypercube, which equal to minimal cell of the current grid
% described by axes_block class.
ch_cube = cur_axes_block.get_axes_scales();
% and convert it into the target coordinate system assuming cube originates
% from the centre of coordinates of the target coordinate system.
%
% TODO: investigate, if this is the best solution:
% Make it half of real size to ensure at least one current grid cell point
% appears in every grid cell of the target grid
trans_chcube = 0.49999*source_proj.from_this_to_targ_coord(ch_cube);
% 0.49999 will give point on edge for 100000 bin -- would never happen in
% real life

% get all nodes belonging to target axes block, doing the
% binning with the bin size, slightly smaller then the current
% lattice size
if source_proj.do_3D_transformation_
    [bin_nodes,dEnodes] = targ_axes_block.get_bin_nodes(trans_chcube,'-3D','-halo');
    [~,baseEdges] = cur_axes_block.get_bin_nodes('-3D','-axes_only');
    n_targ_in_bin = histcounts(dEnodes,baseEdges);
    may_contribure = n_targ_in_bin>0;
    if ~any(may_contribure)
        contrib_ind = [];
        return;
    end
else
    bin_nodes = targ_axes_block.get_bin_nodes(trans_chcube,'-halo');
end
% convert these nodes to the coordinate system, described by
% the existing projection
nodes_here = targ_proj.from_this_to_targ_coord(bin_nodes);
% bin target nodes on the current lattice and return numbers of bins
% contributed into lattice.
nbin_in_bin = cur_axes_block.bin_pixels(nodes_here);
%
% identify cell indexes containing nodes
if source_proj.do_3D_transformation_
    contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
        nbin_in_bin(:)>0,may_contribure);
else
    contrib_ind = find(nbin_in_bin>0);
end
