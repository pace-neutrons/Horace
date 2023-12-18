function [positions,free_spaces,last_gap_pos] = pack_blocks(free_spaces,block_sizes,last_gap_pos)
%PACK_BLOCKS The function places blocks within the array of free spaces
%trying to leave minimal free space.
%
% Inputs:
% free_spaces  -- 2 x n-element array of numbers, defining positions (first
%                 row) and sizes (second row) of gaps to place blocks in.
% block_sizes  -- 1 x m-elements array of numbers defining the sizes of the
%                 blocks to place within the gaps.
% last_gap_position
%              -- the position of the last unlimited size gap, where all
%                 blocks which do not fit free spaces should be placed in.
%                 (current EOF position, where blocks not fitting within
%                 the gaps should be placed).
% Output:
% positions    -- 1 x m-elements array of numbers, defining positions of the
%                 blocks to store.
% free_spaces  -- array of free spaces remaining after blocks were packed
% last_gap_pos -- if blocks do not fit gaps and placed at the end, changes
%                 to point after last byte of the last block placed at the
%                 end. In other words, new EOF position.

check_inputs_throw_error(free_spaces,block_sizes,last_gap_pos);

n_blocks = numel(block_sizes);
[block_sizes,block_ids] =  sort(block_sizes,'descend');
[~,free_idx]= sort(free_spaces(2,:),'descend');
free_spaces = free_spaces(:,free_idx);
positions = zeros(1,n_blocks);
for i = 1:n_blocks
    best_fit = block_sizes(i) == free_spaces(2,:);
    fit_idx = find(best_fit,1);
    if ~isempty(fit_idx)
        positions(block_ids(i)) = free_spaces(1,fit_idx);
        free_spaces(2,fit_idx)  = 0;
        continue;
    end

    fit =block_sizes(i) < free_spaces(2,:);
    fit_idx = find(fit,1);
    if ~isempty(fit_idx)
        positions(block_ids(i)) = free_spaces(1,fit_idx);
        free_spaces(1,fit_idx)  = free_spaces(1,fit_idx) + block_sizes(i);
        free_spaces(2,fit_idx)  = free_spaces(2,fit_idx) - block_sizes(i);
    else
        positions(block_ids(i)) = last_gap_pos;
        last_gap_pos = last_gap_pos+block_sizes(i);
    end
end
% pack free spaces to remove remaining gaps
gap_remains = free_spaces(2,:) >0;
free_spaces = free_spaces(:,gap_remains);

function check_inputs_throw_error(free_spaces,block_sizes,last_gap_position)
% simple check. Fancy validation of data consistency is not performed as is
% not necessary for the purpoce of this ticket. May be performed later if
% the routine usage is extended.
%
if ~isnumeric(free_spaces) || size(free_spaces,1) ~=2
    error('HERBERT:utilities:invalid_argument', ...
        'free_spaces should be numeric array of 2 x n_free_spaces size.\n Actually its class is: %s and size: %s', ...
        class(free_spaces),disp2str(size(free_spaces)));
end
if ~isnumeric(block_sizes) || ~isvector(block_sizes)
    error('HERBERT:utilities:invalid_argument', ...
        'block_sizes array should be numeric vector.\n Actually its class is: %s and size is: %s ',...
        class(block_sizes),disp2str(size(block_sizes)));
end
if ~isnumeric(last_gap_position) || ~isscalar(last_gap_position) || last_gap_position <=0
    error('HERBERT:utilities:invalid_argument', ...
        'last_gap_position should be numeric positive scalar.\n Actually its class is: %s, size: %s and value %s',...
        class(last_gap_position),disp2str(size(last_gap_position)),disp2str(last_gap_position));
end

