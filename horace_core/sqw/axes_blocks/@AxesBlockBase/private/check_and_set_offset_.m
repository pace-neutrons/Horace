function obj = check_and_set_offset_(obj,offset)
% Verify correct values for offset and set offset as a 4-element row
%
if isnumeric(offset)
    if (numel(offset)==3)
        off=[offset(:);0]';
    elseif numel(offset)==4
        off=offset(:)';
    elseif numel(offset) == 1
        off = ones(1,4)*offset;
    elseif isempty(offset)
        off = [0,0,0,0];
    else
        error('HORACE:AxesBlockBase:invalid_argument',...
            'Vector offset must have form [h0,k0,l0] or [h0,k0,l0,e0] or be empty. Actually its size is: %s',...
            evalc('disp(size(offset))'));
    end
    is_small = abs(off)< aProjectionBase.tol_;
    if any(is_small)
        off(is_small) = 0;
    end
elseif isempty(offset)
    off = [0,0,0,0];
else
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Vector offset must have form [h0,k0,l0] or [h0,k0,l0,0] or be empty. Actually it is: %s',...
        evalc('disp(offset)'));
end
obj.offset_ = off;


