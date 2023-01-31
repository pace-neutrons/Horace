function [the_block,bl_ind] = get_data_block_(obj,block_name_or_instance)
% get data block given its name (or class instance with providing name)
if isa(block_name_or_instance,'data_block')
    block_name = block_name_or_instance.block_name;
elseif ischar(block_name_or_instance)||isstring(block_name_or_instance)
    block_name = block_name_or_instance;
else
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'Method accepts either data_block class instance or the name of the block in BAT. The class of the input is %s', ...
        class(block_name_or_instance));
end
nmb = ismember(obj.block_names_,block_name);
if ~any(nmb)
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'The block with name %s is not registered in block allocation table', ...
        block_name);
end
bl_ind = find(nmb);
the_block = obj.blocks_list_{bl_ind};
