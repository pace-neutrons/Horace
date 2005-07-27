function wout = deriv2(w)
% DERIV2  Numerical second derivative of a 1D dataset
%
%   >> wout = deriv2(w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wtemp = deriv2(d1d_to_spectrum(w));
wout = combine_d1d_spectrum (w, wtemp);
