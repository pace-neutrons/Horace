function  contrib_ind = get_contrib_orthocell_ind_(source_proj,...
    cur_axes_block,targ_axes_block)
% return the indexes of cells, which may contain
% the nodes, belonging to the target axes block
%
%
% Get the source grid lattice:
[img_coords,dEgrid] = cur_axes_block.get_bin_nodes('-3D');
bsize = cur_axes_block.nbins_all_dims(1:3)+1; % the size of q_block; (+1 to size(npix) accounting for the left axis range)

bin_range = targ_axes_block.img_range;
[any_inside,e_inside] = AxesBlockBase.bins_in_1Drange(dEgrid,bin_range(:,4));
if ~any_inside
    contrib_ind = [];
    return;
end
% convert q_grid into the target coordinate system
img_coords = source_proj.from_this_to_targ_coord(img_coords);

bin_in = bin_inside(img_coords,bsize,bin_range);
%
contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
    bin_in,e_inside);
