function  [bl_start,bl_size] = get_nrange_(obj,...
    npix,cur_axes_block,targ_proj,targ_axes_block)
% return the bin numbers and the block sizes containing pixels,
% which may contribute to the final cut defined by the
% projections, provided as input

targ_proj.targ_proj = obj;
obj.targ_proj = targ_proj;
% Get the hypercube, which describes the one step of binning
% of the current coordinate axes grid
ch_cube = cur_axes_block.get_axes_scales();
% and convert it into the target lattice
trans_chcube = obj.from_cur_to_targ_coord(ch_cube);

% get all nodes belonging to target axes block, doing the
% binning with the bin size, slightly smaller then the current
% lattice size
bin_nodes = targ_axes_block.get_bin_nodes(trans_chcube);
% convert these notes to the coordinate system, described by
% the existing projection
nodes_here = targ_proj.from_cur_to_targ_coord(bin_nodes);
% bin target nodes on the current lattice
nbin_in_bin = cur_axes_block.bin_pixels(nodes_here);
%
% identify cell numbers containing nodes
cell_num = 1:numel(nbin_in_bin);
ncell_contrib = cell_num(nbin_in_bin>0);
if isempty(ncell_contrib)
    bl_start  = [];
    bl_size = [];
    return;
end
% compress indexes of сontributing cells into bl_start:bl_start+bl_size-1 form
% good for filebased but bad for arrays
adjacent= ncell_contrib(1:end-1)+1==ncell_contrib(2:end);
adjacent = [false,adjacent];
adj_end  = [ncell_contrib(1:end-1)+1<ncell_contrib(2:end),true];
bin_start = [0,cumsum(reshape(npix,1,numel(npix)))]+1;
bl_start  = bin_start(ncell_contrib(~adjacent));
bl_size   = bin_start(ncell_contrib(adj_end))-bl_start+1;
