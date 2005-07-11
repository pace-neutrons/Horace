function wout = uminus(w1)
% UMINUS  Implement -w for 1D dataset

w = -d1d_to_spectrum(w1);
wout = combine_d1d_spectrum (w1, w);