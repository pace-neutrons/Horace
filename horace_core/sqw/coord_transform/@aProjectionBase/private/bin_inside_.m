function is_inside = bin_inside_(img_grid_coord,img_size,targ_range,mark_nodes)
% Found the cells which lie inside the limits provided as input
%
% Input:
% img_grid_coord  -- 3xNcells or 4xNcells array of image coordinates
% img_size        -- array which defines shape of ND image
% targ_range      -- 2x3 or 2x4 array of ranges to specify if
%                    img_grid_coord lie inside or outside of them.
%
% Ouptput:
% is_inside       -- logical array of size Ncells, containing true for
%                    cells which lie inside the target range and false for
%                    outsize cells.


is_inside = ~(bin_outside(1)|bin_outside(2)|bin_outside(3));   % =0 if bin outside, =1 if at least partially intersects volume
if mark_nodes
    is_inside = mark_edge_bins(is_inside,img_size);
end


    function wrk = bin_outside (idim)
        % Determine if the bins lie wholly outside the limits along dimension number idim
        % include range limits
        wrk = reshape(img_grid_coord(idim,:) < targ_range(1,idim),img_size);
        all_low = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = reshape(img_grid_coord(idim,:) > targ_range(2,idim),img_size);
        all_hi  = wrk(1:end-1,1:end-1,1:end-1) & wrk(2:end,1:end-1,1:end-1) & wrk(1:end-1,2:end,1:end-1) & wrk(2:end,2:end,1:end-1) & ...
            wrk(1:end-1,1:end-1,2:end) & wrk(2:end,1:end-1,2:end) & wrk(1:end-1,2:end,2:end) & wrk(2:end,2:end,2:end);
        wrk = all_low | all_hi;

    end

end

function edge_bins = mark_edge_bins(bin_inside,img_size)
edge_bins  = false(img_size);
bin_idx = find(bin_inside(:));
[i1,i2,i3] = ind2sub(img_size-1,bin_idx);
i1 = [i1;i1+1];
i2 = [i2;i2+1];
i3 = [i3;i3+1];
bin_idx = unique(sub2ind(img_size,i1,i2,i3));
edge_bins(bin_idx) = true;

end