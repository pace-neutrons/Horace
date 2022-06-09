function obj = check_and_set_nonorthogonal_(obj,val)
% check and set non-othrogonal property
if numel(val)>1
    error('HORACE:ortho_proj:invalid_argument',...
        ['nonorthogonal property value should be single value,'...
        ' convertable to logical'])
end
obj.nonorthogonal_ = logical(val);
