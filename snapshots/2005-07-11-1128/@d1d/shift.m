function wout = shift(w, xval)
% SHIFT - Moves a 1D dataset along the x-axis
%
% Syntax:
%   >> w_out = shift(w_in, delta)
%
% If DELTA is positive, then the spectrum starts and ends at more positive
% values of x.

wtemp = shift(d1d_to_spectrum(w), xval);
wout = combine_d1d_spectrum (w, wtemp);
