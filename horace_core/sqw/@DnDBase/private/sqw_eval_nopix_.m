function obj = sqw_eval_nopix_(obj, sqwfunc, pars,options)
% SQW_EVAL_NOPIX_
%
% Helper function for sqw eval executed on a pixel-less object (DnD with no pixels
% Called by `sqw_eval_` defined in sqw/DnDBase
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%   pars        Arguments needed by the function.
%   options    -- the structue containing settings controlling the
%                 algorithms
% Used fields ields of the structure are:
%   .all_bins    Boolean flag either to apply function to all bins or only those containing data
%
%=================================================================

qw = calculate_qw_bins(obj);
if ~options.all_bins       % only evaluate at the bins actually containing data
    ok = (obj.npix ~= 0);   % should be faster than isfinite(1./win.data_.npix), as we know that npix is zero or finite
    for idim = 1:4
        qw{idim} = qw{idim}(ok);  % pick out only the points where there is data
    end
    obj.s(ok) = sqwfunc(qw{:}, pars{:});
else
    obj.s = reshape(sqwfunc(qw{:}, pars{:}), size(obj.s));
end
obj.e = zeros(size(obj.e));
end

