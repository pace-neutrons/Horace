function [chunks, cumulative_sum] = split_data_blocks(start_pos,block_sizes, buf_size)
% Split the array of the data blocks into the blocks, which have equal or
% almost equal size
%
% Input:
% ------
% start_pos          A vector of numeric, non-negative, values describing a
%                    positions of blocks on some media
% block_sizes        A vector of numeric, non-negative, values describing
%                    block sizes, to process. Its assumed that the block is
%                    continuously located on the media.
% buf_size           A positive value specifying the limiting size for each
%                    sub-block, the initial values need to be split into
%                    The actual size should be the range from this size to
%                    double of the buffer size
%
%
% Output:
% -------
% chunks          Cell array of cells, containing parts of the start_val
%                 and block_sizes array.
%                 {start_val(part),block_sizes(part)}
%                 split in such way, that sum(block_sizes(part))==max_chunk_sum
%                 for every chunk except the final one. The final may
%                 sum for final chunk may contain less data, i.e.
%                 sum(block_sizes(last part))<=max_chunk_sum
% cumulative_sum  The cumulative sum of 'block_sizes'.
%

if isempty(block_sizes)
    chunks = {};
    cumulative_sum = [];
    return;
end
validateattributes(start_pos, {'numeric'}, {'vector', 'positive'});
validateattributes(block_sizes, {'numeric'}, {'vector', 'positive'});
validateattributes(buf_size, {'numeric'}, {'scalar', 'positive'});
if any(size(start_pos)~=size(block_sizes))
    error('HORACE:utilities:invalid_argument',...
        'The size of start_val array and size of block_sizes array have to be the same');
end
if size(start_pos,1)>size(start_pos,2) % we want it to be rows
    start_pos = start_pos';
end
if size(block_sizes,1)>size(block_sizes,2) % we want it to be rows
    block_sizes = block_sizes';
end
% glue adjacent data blocks
cumulative_sum = cumsum(block_sizes);
last_block_pos = block_sizes+start_pos;
% remove border between adjacent blocks
remove_border  = start_pos(2:end)==last_block_pos(1:end-1);
if any(remove_border)    
    % number of blocks to keep is equal to the number of borders +1
    n_unique_blocks = sum(~remove_border)+1;
    block_ind = ones(1
    
    for i=1:n_unique_blocks 
    end
    % cell previous to the cell indexed as adjacent is adjacent too
    adj(remove_border) = true;    
    adj_ind_end = find(remove_border);
    adj_ind_start = adj_ind_end-1;
    start_unique_pos = start_pos(non_adj);
    
    block_ind = 1:numel(blocks);
    adj_bl_start_ind  = block_ind()
    adj_ind = ismember(start_pos,start_unique_pos);
    

end

% split blocks not fitting double buffer into separate blocks
if any(block_sizes>2*buf_size) % split big ranges into parts to fit buffer.
    [cell_range,cell_offcet] = arrayfun(@(rg,offs)split_ranges(rg,offs,buf_size),...
        block_sizes,start_pos,'UniformOutput',false);
    block_sizes = [cell_range{:}];
    block_sizes = cell2mat(block_sizes);
    start_pos   = [cell_offcet{:}];
    start_pos   = cell2mat(start_pos);
    cumulative_sum = cumsum(block_sizes);    
end




max_num_chunks = floor(cumulative_sum(end)/buf_size);
if max_num_chunks*buf_size<cumulative_sum(end)
    max_num_chunks = max_num_chunks+1;
end

if (max_num_chunks == 1) || (ceil(cumulative_sum(end)/buf_size) == 1)
    % Only one chunk of data, return it
    chunks = {{start_pos',block_sizes'}};
    return
end

chunks = cell(1, max_num_chunks);
run_sum = buf_size;
first_ind = 1;
for i=1:max_num_chunks
    
    last_ind = find(cumulative_sum >= run_sum,1);
    if isempty(last_ind)
        chunks{i} = {start_pos(first_ind:end)',block_sizes(first_ind:end)'};
        break;
    end
    chunks{i} = {start_pos(first_ind:last_ind)',block_sizes(first_ind:last_ind)'};
    first_ind  = last_ind+1;
    
    run_sum = cumulative_sum(last_ind)+buf_size;
    
end

%
%--------------------
function [cell_rg,cell_off] = split_ranges(range,offset,buf_size)
% split ranges bigger than buf size into approximately buf-size chunks.
if range<2*buf_size
    cell_rg = {range};
    cell_off = {offset};
    return;
end
%
n_cells = floor(range/buf_size)+1;
cell_rg = cell(1,n_cells);
cell_off = cell(1,n_cells);
cell_rg{1} = buf_size;
cell_off{1}= offset;
for i=2:n_cells
    t_range = buf_size;
    shift = buf_size*(i-1);
    if shift+t_range > range; t_range = range-shift; end
    if t_range > 0
        cell_rg{i} = t_range;
    end
    cell_off{i} = 0;
end
