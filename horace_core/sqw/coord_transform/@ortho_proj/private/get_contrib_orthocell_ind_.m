function  contrib_ind = get_contrib_orthocell_ind_(source_proj,...
    cur_axes_block,targ_axes_block)
% return the indexes of cells, which may contain
% the nodes, belonging to the target axes block
%
%
% Get the source grid lattice:
[q_coords,dEgrid] = cur_axes_block.get_bin_nodes('-3D');
bsize = cur_axes_block.nbins_all_dims(1:3)+1; % the size of q_block; (+1 to size(npix) accounting for the left axis range)

bin_range = targ_axes_block.img_range;
[any_inside,e_inside] = axes_block.bins_in_1Drange(dEgrid,bin_range(:,4));
if ~any_inside
    contrib_ind = [];
    return;
end
% convert q_grid into the target coordinate system
q_coords = source_proj.from_this_to_targ_coord(q_coords);

bin_inside = ~(bin_outside(1)|bin_outside(2)|bin_outside(3));   % =0 if bin outside, =1 if at least partially intersects volume
%
contrib_ind = source_proj.convert_3Dplus1Ind_to_4Dind_ranges(...
    bin_inside,e_inside);

    function wrk = bin_outside (idim)
        % Determine if the bins lie wholly outside the limits along dimension number idim
        % include range limits
        wrk = reshape(q_coords(idim,:) < bin_range(1,idim),bsize);
        all_low = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = reshape(q_coords(idim,:) > bin_range(2,idim),bsize);
        all_hi  = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = all_low | all_hi;
    end

end