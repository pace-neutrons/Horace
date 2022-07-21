function obj = check_combo_arg_(obj)
% Check contents of interdependent fields
% ------------------------
sz = size(obj.s_);
if any(sz ~= size(obj.e_))
    error('HORACE:DnDBase:invalid_argument', ...
        'size of signal array: [%s] different from size of error array: [%s]', ...
        num2str(sz),num2str(size(obj.e_)));
end

if any(sz ~= size(obj.npix_))
    error('HORACE:DnDBase:invalid_argument', ...
        'size of npix array: [%s] different from sizes of signal and error array: [%s]', ...
        num2str(sz),num2str(size(obj.npix_)))
end

if any(sz ~=obj.axes.dims_as_ssize)
    error('HORACE:DnDBase:invalid_argument', ...
        'size of data arrays: [%s] different from the size of the grid, defined by axes: [%s]', ...
        num2str(sz),num2str(obj.axes.dims_as_ssize) )
end
