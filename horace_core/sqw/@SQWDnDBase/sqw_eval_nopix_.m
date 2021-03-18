function obj = sqw_eval_nopix_(obj, sqwfunc, all_bins, pars)
% SQW_EVAL_NOPIX_
%
% Helper function for sqw eval executed on a pixel-less object (i.e. DnD or SQW with no pixels
% Called by `sqw_eval_` defined in sqw/DnDBase
%
% Input:
% ------
%   obj        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q,w)
%   all_bins    Boolean flag wither to apply function to all bins or only those contaiing data
%   pars       Arguments needed by the function.
%
   qw = calculate_qw_bins(obj);
   if ~all_bins                      % only evaluate at the bins actually containing data
       ok = (obj.data_.npix ~= 0);   % should be faster than isfinite(1./win.data_.npix), as we know that npix is zero or finite
       for idim = 1:4
           qw{idim} = qw{idim}(ok);  % pick out only the points where there is data
       end
       obj.data_.s(ok) = sqwfunc(qw{:}, pars{:});
   else
       obj.data_.s = reshape(sqwfunc(qw{:}, pars{:}), size(obj.data_.s));
   end
   obj.data_.e = zeros(size(obj.data_.e));
end

