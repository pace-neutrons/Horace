function obj = set_block_list_(obj,val)
% Body of block_list class setter
%
%
if ~iscell(val)
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'Block list value should be cellarray of data_block classes. It is: %s',...
        class(val))
end
is_db = cellfun(@(x)isa(x,'data_block'),val);
if ~all(is_db)
    first_non = find(~is_db);
    error('HORACE:blockAllocationTable:invalid_argument', ...
        ['Block list value should be cellarray of data_block classes.\n',...
        'First non-data_block number is %d and its class is: %s'],...
        first_non,class(val{first_non}));
end
obj.blocks_list_ = val;

[total_bl_size,initialized,bat_blocks_size,block_names,eof_pos] = calculate_bat_size_and_free_spaces(obj);
obj.bat_blocks_size_ = bat_blocks_size; % (initial 4 bytes of bat size has been accounded for)
obj.block_names_  = block_names;


if ~initialized
    % EOF position in empty file -- first position+ 4 bytes BAT size +
    % binary BAT representation itself
    obj.end_of_file_pos_ = obj.position_+ obj.bat_bin_size;
    obj.initialized_ = false;
    return % block list is not initialized
end
obj.initialized_     = true;
obj.end_of_file_pos_ = eof_pos;
if obj.blocks_start_position+total_bl_size ~=eof_pos  % free spaces between blocks
    obj = find_free_spaces(obj);
end

function [bl_contents_size,initialized,bat_blocks_size,name_list,eof_pos] = calculate_bat_size_and_free_spaces(obj)
% calculate the size of the block allocation table to store it on disk
%
% Initial blocks size. First number defines the number of blocks.
n_blocks = numel(obj.blocks_list_);
if n_blocks == 0
    bat_blocks_size = 0; % If no no blocks are there the previous record states
    % that length of the BAT record is 0.
else
    bat_blocks_size = 4; % initial BAT block size is 4 (4 bytes to store
    % BAT's blocks number in BAT.
end
name_list     = cell(1,n_blocks);
eof_pos       = bat_blocks_size;
bl_contents_size = 0;
initialized   = false;
for i=1:n_blocks
    block = obj.blocks_list_{i};
    initialized = initialized||block.allocated;
    bl_contents_size = bl_contents_size +block.size;
    bat_blocks_size = bat_blocks_size + block.bat_record_size;
    name_list{i} = block.block_name;
    if initialized
        eof_pos = max(eof_pos,block.position+block.size);
    else
        eof_pos  = bat_blocks_size;
    end
end

function obj = find_free_spaces(obj)
% find spaces between blocks
n_blocks = numel(obj.blocks_list_);
bl_ps = zeros(2,n_blocks+1); % block positions and sizes to calculate free spaces between blocks
% first block is BAT and everything before it:
bl_ps(1,1) = 0;
bl_ps(2,1) = obj.blocks_start_position;

for i=1:n_blocks
    block = obj.blocks_list_{i};
    bl_ps(1,i+1) = block.position;
    bl_ps(2,i+1) = block.size;
end
if any(bl_ps(1,2:end)<obj.blocks_start_position)
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'Data block location overlaps with the space, occupied by BAT')
end

[~,indx] = sort(bl_ps(1,:));
bl_ps = bl_ps(:,indx);
bl_ps_end = bl_ps(1,:)+bl_ps(2,:);
empty_spaces = bl_ps(1,2:end)-bl_ps_end(1:end-1);
if any(empty_spaces<0)
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'Some blocks overlep with each other. BAT is invalid');
end
free_space_id = empty_spaces>0;
bl_ps_end = bl_ps_end(1:end-1);
obj.free_spaces_and_size_ = ...
    [bl_ps_end(free_space_id);empty_spaces(free_space_id)];