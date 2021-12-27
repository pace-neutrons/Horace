function obj = check_and_set_offset_(obj,offset)
% Verify correct values for offset and set offset field
% if validation is successful
%
if isnumeric(offset)
    if (numel(offset)==3)
        off_=[offset(:);0]';
    elseif numel(offset)==4
        off_=offset(:)';
    elseif numel(offset) == 1
        off_ = ones(1,4)*offset;
    elseif isempty(offset)
        off_ = [0,0,0,0];
    else
        error('HORACE:aProjection:invalid_argument',...
            'Vector offset must have form [h0,k0,l0] or [h0,k0,l0,e0] or be empty. Actually its size is: %s',...
            evalc('disp(size(offset))'));
    end
    is_small = abs(off_)<obj.tol_;
    if any(is_small)
        off_(is_small) = 0;
    end
    obj.offset_ = off_;
elseif isempty(offset)
    obj.offset_ = [0,0,0,0];
else
    error('HORACE:aProjection:invalid_argument',...
        'Vector offset must have form [h0,k0,l0] or [h0,k0,l0,0] or be empty. Actually it is: %s',...
        evalc('disp(offset)'));
end


