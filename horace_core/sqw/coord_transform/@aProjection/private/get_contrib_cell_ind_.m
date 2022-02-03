function  contrib_ind = get_contrib_cell_ind_(source_proj,...
    cur_axes_block,targ_proj,targ_axes_block)
% return the indexes of cells, which may contain
% the nodes, belonging to the target axes block
%
%
if isempty(targ_proj)
    targ_proj = source_proj.targ_proj;
end
% Get the hypercube, which equal to minimal cell of the current grid
% described by axes_block class.
ch_cube = cur_axes_block.get_axes_scales();
% and convert it into the target coordinate system assuming it starts from
% the beginning of the target coordinate system. For ortho-ortho
% transformation its
trans_chcube = source_proj.from_this_to_targ_coord(ch_cube);

% get all nodes belonging to target axes block, doing the
% binning with the bin size, slightly smaller then the current
% lattice size
if source_proj.do_3D_transformation_
    [bin_nodes,dEnodes] = targ_axes_block.get_bin_nodes(trans_chcube,'-3D','-halo');
    bin_range = targ_axes_block.img_range;
    [any_inside,e_inside] = axes_block.bins_in_1Drange(dEnodes,bin_range(:,4));
    if ~any_inside
        contrib_ind = [];
        return;
    end
else
    bin_nodes = targ_axes_block.get_bin_nodes(trans_chcube,'-halo');
end
% convert these notes to the coordinate system, described by
% the existing projection
nodes_here = targ_proj.from_this_to_targ_coord(bin_nodes);
% bin target nodes on the current lattice and return numbers of bins
% contributed into lattice.
nbin_in_bin = cur_axes_block.bin_pixels(nodes_here);
%
% identify cell indexes containing nodes
if source_proj.do_3D_transformation_
    contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
        nbin_in_bin(:)>0,e_inside);
else
    contrib_ind = find(nbin_in_bin>0);
end
