function obj = sqw_eval_nopix_(obj, sqwfunc, all_bins, pars)
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

