function obj = apply(obj, func_handle, args, recompute_bins, compute_variance)
% Apply a function (`func_handle`) to pixels (`obj`) with extra arguments `args`
% and recomputes the DnD image if requested.
%
% Inputs:
% obj   --  initialised sqw object
%
% func_handle
%       -- Function handle or cell array of function handles to apply
%          `func_handle` must have a signature corresponding to:
%
%        pix_obj = func_handle(pix_obj, args{1}, ..., args{N})
%
%        N.B. `args` are the same for each function
%   args
%        cell-array of extra args to pass to `func_handle`
% Optional:
%  recompute_bins  -- if false, do not recalculate change in image caused by
%                    changes in pixels
%  compute_variance
%                 -- if true, compute variance as changes of signal within
%                    the cell rather than using PixelData variance.
if ~exist('compute_variance', 'var')
    compute_variance = false;
end

if ~exist('recompute_bins', 'var')
    recompute_bins = true;
end

if ~exist('args', 'var') || isempty(args)
    args = {{}};
end

page_op = PageOp_apply();
page_op = page_op.init(obj,func_handle,args,compute_variance,recompute_bins);

obj = sqw.apply_op(obj,page_op);

