function obj = set_bat_position_(obj,val)
% The body of block allocation table setter
% containing validator and
if ~(isnumeric(val)&&isscalar(val)&&val>=0)
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'Allocation block position should be defined by non-negative scalar. It is %s', ...
        disp2str(val));
end
old_pos = obj.position_;
obj.position_ = val;
pos_shift = val-old_pos;
if pos_shift ~= 0 && obj.initialized_
    for i=1:obj.n_blocks
        obj.blocks_list_{i}.position = ...
            obj.blocks_list_{i}.position + pos_shift;
    end
end

