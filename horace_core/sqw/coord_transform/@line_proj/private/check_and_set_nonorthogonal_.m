function obj = check_and_set_nonorthogonal_(obj,val)
% check and set non-orthogonal property
if numel(val)>1
    error('HORACE:line_proj:invalid_argument',...
        ['nonorthogonal property value should be single value,'...
        ' convertible to logical'])
end
obj.nonorthogonal_ = logical(val);
