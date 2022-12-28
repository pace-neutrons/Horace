function obj = set_block_list_(obj,val)
% Body of block_list class setter
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
[bl_size,block_names,eof_pos] = calculate_bat_size_(obj);
obj.bat_bin_size_ = bl_size;
obj.block_names_ = block_names;
obj.end_of_file_pos_ = eof_pos;

function [blksize,name_list,eof_pos] = calculate_bat_size_(obj)
% calculate the size of the block allocation table to store it on disk
%
blksize = 4; % first 4 bytes of BAT is number of blocks in the record
n_blocks = numel(obj.blocks_list_);
name_list = cell(1,n_blocks);
eof_pos = 0;
for i=1:n_blocks
    block = obj.blocks_list_{i};
    blksize = blksize+block.bat_record_size;
    name_list{i} = block.block_name;
    eof_pos = max(eof_pos,block.position+block.size);
end
