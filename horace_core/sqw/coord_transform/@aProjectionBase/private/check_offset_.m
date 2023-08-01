function off = check_offset_(obj,offset)
% Verify correct values for offset and return offset as a 4-element row
%
if isempty(offset)
    off = [0,0,0,0];
elseif isnumeric(offset)
    if (numel(offset)==3)
        off=[offset(:);0]';
    elseif numel(offset)==4
        off=offset(:)';
    elseif numel(offset) == 1
        off = ones(1,4)*offset;
    else
        error('HORACE:aProjectionBase:invalid_argument',...
            'Vector offset must have form [h0,k0,l0] or [h0,k0,l0,e0] or be empty. Actually its size is: %s',...
            evalc('disp(size(offset))'));
    end
    is_small = abs(off)<obj.tol_;
    if any(is_small)
        off(is_small) = 0;
    end
else
    error('HORACE:aProjectionBase:invalid_argument',...
        'Vector offset must have form [h0,k0,l0] or [h0,k0,l0,0] or be empty. Actually it is: %s',...
        evalc('disp(offset)'));
end
