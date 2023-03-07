function wout = recompute_bin_data(w)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)

wout = w;
[wout.data.s, wout.data.e] = wout.pix.compute_bin_data(w.data.npix);

end
