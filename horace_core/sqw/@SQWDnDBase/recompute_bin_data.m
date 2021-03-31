function wout = recompute_bin_data(w)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)

% See also average_bin_data, which uses en essentially the same algorithm. Any changes
% to the one routine must be propagated to the other.

wout = w;
[wout.data.s, wout.data.e] = wout.data_.pix.compute_bin_data(w.data.npix);
