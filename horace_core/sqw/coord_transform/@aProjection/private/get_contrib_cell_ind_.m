function  contrib_ind = get_contrib_cell_ind_(obj,...
    cur_axes_block,targ_proj,targ_axes_block)
% return the indexes of cells, which may contain
% the nodes, belonging to the target axes block
%
%
if isempty(targ_proj)
    targ_proj = obj.targ_proj;
else
    targ_proj.targ_proj = obj;
    obj.targ_proj = targ_proj;
end
% Get the hypercube, which equal to minimal cell of the current grid
% described by axes_block class.
ch_cube = cur_axes_block.get_axes_scales();
% and convert it into the target coordinate system
trans_chcube = obj.from_cur_to_targ_coord(ch_cube);

% get all nodes belonging to target axes block, doing the
% binning with the bin size, slightly smaller then the current
% lattice size
bin_nodes = targ_axes_block.get_bin_nodes(trans_chcube);
% convert these notes to the coordinate system, described by
% the existing projection
nodes_here = targ_proj.from_cur_to_targ_coord(bin_nodes);
% bin target nodes on the current lattice and return numbers of bins
% contributed into lattice.
nbin_in_bin = cur_axes_block.bin_pixels(nodes_here);
%
% identify cell indexes containing nodes
contrib_ind = find(nbin_in_bin>0);
