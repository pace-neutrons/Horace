function positions = pack_blocks(free_spaces,block_sizes,last_gap_position)
%PACK_BLOCKS The function places blocks within the array of free spaces
%trying to leave minimal free space.
%
% Inputs:
% free_spaces  -- 2xn_element array of numbers, defining positions (first
%                 row and sizes (second row) of gaps to place blocks in.
% block_sizes  -- 1xm_elements array of numbers defining the sizes of the
%                 blocks to place within the gaps.
%last_gap_position
%              -- the position of the last unlimited size gap, where all
%                 blocks which do not fit free spaces should be placed in.
%                 (current EOF position, where blocks not fitting within
%                 the gaps should be places
% Output:
% positions    -- 1xm_elements array of numbers, defining positions of the
%                 blocks to store.
check_inputs_throw_error(free_spaces,block_sizes,last_gap_position);

n_blocks = numel(block_sizes);
[block_sizes,block_ids] = sort(block_sizes,[],'descent');
free_spaces  = sort(free_spaces,2,'descent');
positions = zeros(1,n_blocks);
for i = 1:n_blocks
    good_fit = block_sizes(i) == free_spaces(2,:);
    fit_idx  = find(good_fit,1);
    if ~isempty(fit_idx)
        positions(block_ids(i)) = free_spaces(1,fit_idx);
        free_spaces(2,fit_idx)  = 0;
        continue;
    end
    fit =block_sizes(i) < free_spaces(2,:);
    fit_idx = find(fit,1);
    if ~isempty(fit_idx)
        positions(block_ids(i)) = free_spaces(1,fit_idx);
        free_spaces(2,fit_idx)  = free_spaces(2,fit_idx) - block_sizes(i);
    else
        positions(block_ids(i)) = last_gap_position;
        last_gap_position = last_gap_position+block_sizes(i);
    end
end