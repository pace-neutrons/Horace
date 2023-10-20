function obj = apply(obj, func_handle, args, recompute_bins, compute_variance)
if ~exist('args', 'var')
    args = {};
end
if ~exist('recompute_bins', 'var')
    recompute_bins = true;
end
if ~exist('compute_variance', 'var')
    compute_variance = false;
end

if recompute_bins
    [obj.pix, obj.data] = obj.pix.apply(func_handle, args, obj.data, compute_variance);
else
    obj.pix = obj.pix.apply(func_handle, args);
end
end
