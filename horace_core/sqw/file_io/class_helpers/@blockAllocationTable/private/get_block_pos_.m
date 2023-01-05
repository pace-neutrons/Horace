function pos = get_block_pos_(obj,block)
% return the position of block defined by current BAT
% Inputs:
% obj -- the instance of block_allocation table initialized by
%        an object
% block_name
%     -- name of the data block to find the position
% Throws:
% HORACE:blockAllocationTable:runtime_error if the table have
%       not been initialized

if ~obj.initialized_
    error('HORACE:blockAllocationTable:runtime_error',...
        'Attempt to obtain block position, but the BAT have not been initialized')
end
%
if isa(block,'data_block') % block provided itself
    block_name = block.block_name;
elseif ischar(block)
    block_name = block;
end
%
bind = ismember(obj.block_names,block_name);
if ~any(bind)
    error('HORACE:blockAllocationTable:invalid_argument',...
        'Block with Name %s is not among the blocks, defined in BAT', ...
        block)
end
bl =  obj.blocks_list_{bind};
pos = bl.position;
