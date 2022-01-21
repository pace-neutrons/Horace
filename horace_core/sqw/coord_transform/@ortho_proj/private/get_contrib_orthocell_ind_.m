function  contrib_ind = get_contrib_orthocell_ind_(source_proj,...
    cur_axes_block,targ_axes_block)
% return the indexes of cells, which may contain
% the nodes, belonging to the target axes block
%
%
% Get the source grid lattice:
[q_coords,dEgrid] = cur_axes_block.get_bin_nodes();
[~,psize] = cur_axes_block.data_dims();
psize = psize(1:3); % the size of q_block

bin_range = targ_axes_block.get_binning_range();
e_inside = dEgrid>=bin_range(1,4) & dEgrid<=bin_range(2,4);
ind_e = find(e_inside,1);
if isempty(ind_e)
    contrib_ind = [];
    return;
end
% convert q_grid into the target coordinate system
q_coords = source_proj.from_this_to_targ_coord(q_coords);

bin_inside = ~(bin_outside(1)|bin_outside(2)|bin_outside(3));   % =0 if bin outside, =1 if at least partially intersects volume
%
change = diff([false;bin_inside(:);false]);
istart = find(change==1);
iend   = find(change==-1)-1;
if isempty(istart)
    contrib_ind = [];
    return;
end
% calculate full 4D indexes from the the knowlege of the contributing dE bins,
% 3D indexes and 4D array allocation layout
q_block_size= prod(psize); % the size of q_block in memory for each dE bin
q_stride = (0:numel(dEgrid)-1)*q_block_size; % the shift of indexes for 
                                             % every subsequent dE block
q_stride = q_stride(e_inside); % only contributing dE blocks matter
n_eblocks = numel(q_stride);
q_stride = repmat(q_stride,numel(istart),1); % expand to every q-block

istart = repmat(istart,1,n_eblocks)+q_stride;
iend  = repmat(iend,1,n_eblocks)+q_stride;
contrib_ind = {reshape(istart,1,numel(istart)),reshape(iend,1,numel(istart))};

    function wrk = bin_outside (idim)
        % Determine if the bins lie wholly outside the limits along dimension number idim
        wrk = reshape(q_coords(idim,:)<bin_range(1,idim),psize);
        all_low = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = reshape(q_coords(idim,:)> bin_range(2,idim),psize);
        all_hi  = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = all_low | all_hi;
    end

end