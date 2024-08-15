function obj = set_bat_position_(obj,val)
% The body of block allocation table setter.
%
% containing validator for the acceptable position value
% and modifies the positions of the data blocks and free spaces blocks 
% stored in the BAT to account for the changes in the BAT position.
%
if ~(isnumeric(val)&&isscalar(val)&&val>=0)
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'Allocation block position should be defined by non-negative scalar. It is %s', ...
        disp2str(val));
end
old_pos = obj.position_;
obj.position_ = val;
pos_shift = val-old_pos;
if pos_shift == 0 || ~obj.initialized
    return
end
% modify the positions of the data blocks on hdd
for i=1:obj.n_blocks
    obj.blocks_list_{i}.position = ...
        obj.blocks_list_{i}.position + pos_shift;
end
% modify the positions of the free spaces on hdd
for i=1:size(obj.free_spaces_and_size_,2)
    obj.free_spaces_and_size_(1,i) = obj.free_spaces_and_size_(1,i) + pos_shift;
end


