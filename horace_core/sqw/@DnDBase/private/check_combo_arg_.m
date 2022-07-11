function obj = check_combo_arg_(obj)
% Check contents of interdependent fields
% ------------------------
sz = size(obj.s_);
if any(sz ~= size(obj.e_))
    error('HORACE:DnDBase:invalid_argument', ...
        'size of signal array different from size of error array')
end

if any(sz ~= size(obj.npix_))
    error('HORACE:DnDBase:invalid_argument', ...
        'size of npix array different from sizes of signal and error array')
end
