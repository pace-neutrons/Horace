function wout = shift(w, xval)
% SHIFT - Moves a 1D dataset along the x-axis
%
% Syntax:
%   >> w_out = shift(w_in, delta)
%
% If DELTA is positive, then the spectrum starts and ends at more positive
% values of x.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wtemp = shift(d1d_to_spectrum(w), xval);
wout = combine_d1d_spectrum (w, wtemp);
