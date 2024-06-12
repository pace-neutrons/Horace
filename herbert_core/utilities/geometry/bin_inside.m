function is_inside = bin_inside(img_grid_coord,img_size,targ_range,mark_nodes)
% Found the cells or edges which lie inside the limits provided as input.
%
% Input:
% img_grid_coord  -- 3xNcells or 4xNcells array of image coordinates
% img_size        -- array which defines shape of ND image
% targ_range      -- 2x3 or 2x4 array of ranges to specify if
%                    img_grid_coord lie inside or outside of them.
% mark_nodes      -- return contributing nodes rather then bin centers if
%                    this option is set to true;
%
% Ouptput:
% is_inside       -- logical array of size Ncells, containing true for
%                    cells which lie inside the target range and false for
%                    outsize cells.
%   or  (if mark_nodes == true) 
%                 -- logical array of size img_size, containing true
%                    for all nodes which lay inside (or at the edge)
%                    of the target range.

if nargin<4
    mark_nodes = false;
end

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

function expanded_bins = mark_edge_bins(bin_inside,img_size)
expanded_bins  = false(img_size);
expanded_bins(bin_inside)=true;
expanded_bins = expanded_bins|mark_edges(1)|mark_edges(2)|mark_edges(3);

    function edge_bins = mark_edges(idim)
        sz = img_size;
        sz(idim) = sz(idim)-1;
        [i1,i2,i3] = ind2sub(sz,find(diff(bin_inside,[],idim)<0));
        add = zeros(3,1);
        add(idim) = 1;
        i1 = i1+add(1);
        i2 = i2+add(2);
        i3 = i3+add(3);
        edge_bins(i1,i2,i3)= true;
    end

end