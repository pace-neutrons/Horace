function [chunks, cumulative_sum] = split_data_blocks(start_val,block_sizes, max_chunk_sum)
% Split the array of the data blocks into the blocks, which have equal or
% almost equal size
%
% Input:
% ------
% start_val          A vector of numeric, non-negative, values describing a
%                    position of a block on some media
% block_sizes        A vector of numeric, non-negative, values describing
%                    block sizes, to process. Its assumed that the block is
%                    continuously located on the media.
% max_chunk_sum      A positive value specifying the maximum sum for each
%                    sub-block, the initial values need to be split into
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
validateattributes(start_val, {'numeric'}, {'vector', 'positive'});
validateattributes(block_sizes, {'numeric'}, {'vector', 'positive'});
validateattributes(max_chunk_sum, {'numeric'}, {'scalar', 'positive'});
if any(size(start_val)~=size(block_sizes))
    error('HORACE:utilities:invalid_argument',...
        'The size of start_val array and size of block_sizes array have to be the same');
end
if size(start_val,1)>size(start_val,2) % we want it to be rows
    start_val = start_val';    
end
if size(block_sizes,1)>size(block_sizes,2) % we want it to be rows
    block_sizes = block_sizes';    
end



cumulative_sum = cumsum(block_sizes);
max_num_chunks = floor(cumulative_sum(end)/max_chunk_sum);
if max_num_chunks*max_chunk_sum<cumulative_sum(end)
    max_num_chunks = max_num_chunks+1;
end

if (max_num_chunks == 1) || (ceil(cumulative_sum(end)/max_chunk_sum) == 1)
    % Only one chunk of data, return it
    chunks = {{start_val',block_sizes'}};
    return
end

chunks = cell(1, max_num_chunks);
chunks_borders = max_chunk_sum:max_chunk_sum:max_num_chunks*max_chunk_sum;
chunks_borders(end)=cumulative_sum(end);
%[counts,~,indexes]= histcounts(chunks_borders,[0,cumulative_sum+0.1]);

ind_end = 0;
ind_prev = 0;
border0 = 0;
for i=1:max_num_chunks
    
    ind_start = ind_end+1;
    ind_end = find(cumulative_sum<=chunks_borders(i),1,'last');
    if isempty(ind_end) || ind_end < ind_start
        ind_end  = ind_start;
    end
    if ind_start ~= ind_prev 
       start_pos   = start_val(ind_start); 
        if i==1
            border0 = 0;
        else
            border0  = chunks_borders(i-1);        
        end       
    end
    
    overrun = chunks_borders(i)-cumulative_sum(ind_end);
    if overrun>0
        chunks{i} = {start_val(ind_start:ind_end+1),...
            [block_sizes(ind_start:ind_end),overrun]};
        % cut the part of the taken block from the beginning of the next
        % block
        start_val(ind_end+1) = start_val(ind_end+1)+overrun;
        block_sizes(ind_end+1) = block_sizes(ind_end+1)-overrun;
    elseif overrun<0 % splitting chunk in more then one block
        chunks{i} = {start_val(ind_end),max_chunk_sum};
        block_sizes(ind_end) = block_sizes(ind_end)-max_chunk_sum;
        start_val(ind_end) =   start_pos+chunks_borders(i)-border0;        
        ind_end = ind_start-1;
    else
        chunks{i} = {start_val(ind_start:ind_end),...
            block_sizes(ind_start:ind_end)};
    end
    ind_prev = ind_start;
end
