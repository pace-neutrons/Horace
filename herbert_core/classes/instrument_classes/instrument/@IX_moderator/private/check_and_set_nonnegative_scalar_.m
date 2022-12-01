function   obj = check_and_set_nonnegative_scalar_(obj,prop_name,val)
%
if isscalar(val) && isnumeric(val) && val>=0
    obj.([prop_name,'_'])=val;
else
    error('HORACE:IX_moderator:invalid_argument',...
        'Selected %s must be a numeric scalar greater or equal to zero. It is %s', ...
        prop_name,disp2str(val))
end
