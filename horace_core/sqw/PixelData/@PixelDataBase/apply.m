function obj = apply(obj, func_handle, args, recompute_bins, compute_variance)
% Apply a function (`func_handle`) to pixels (`obj`) with extra arguments `args`
%
% Inputs:
%
%   obj
%        PixelData object
%
%   func_handle
%        Function handle or cell array of function handles to apply
%        `func_handle` must have a signature corresponding to:
%
%        pix_obj = func_handle(pix_obj, args{1}, ..., args{N})
%
%        N.B. `args` are the same for each function
%
%   args
%        cell-array of extra args to pass to `func_handle`
%

if ~exist('recompute_bins', 'var')
    recompute_bins = false;
end
if ~exist('compute_variance', 'var')
    compute_variance = false;
end

if ~exist('args', 'var') || isempty(args)
    args = {{}};
end


page_op = PageOp_apply();
page_op = page_op.init(obj,func_handle,args,compute_variance,recompute_bins);

obj = obj.apply_op(obj,page_op);
