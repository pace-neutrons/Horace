function wout = deriv2(w)
% DERIV2  Numerical second derivative of a 1D dataset

wtemp = deriv2(d1d_to_spectrum(w));
wout = combine_d1d_spectrum (w, wtemp);
