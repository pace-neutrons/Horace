function obj = check_and_set_positive_scalar_(obj,prop_name,val)
if isscalar(val) && isnumeric(val) && val>=0
    obj.(prop_name)=val;
else
    error('HERBERT:IX_doubledisk_chopper:invalid_argument', ...
        'Disk chopper %s must be a numeric scalar greater or equal to zero',...
        prop_name(1:end-1));
end
