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
obj.bat_bin_size_ = calculate_bat_size_(obj);

function size = calculate_bat_size_(obj)
% calculate the size of the block allocation table to store it on disk
%
size = 4; % first 4 bytes of BAT is number of blocks in the record
for i=1:numel(obj.blocks_list_)
    size = size+obj.blocks_list_{i}.bat_record_size;
end
