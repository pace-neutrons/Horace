function wout = deriv(w)
% DERIV  Numerical first derivative of a 1D dataset

wtemp = deriv(d1d_to_spectrum(w));
wout = combine_d1d_spectrum (w, wtemp);
