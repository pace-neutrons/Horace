function wout = deriv(w)
% DERIV  Numerical first derivative of a 1D dataset
%
%   >> wout = deriv(w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wtemp = deriv(d1d_to_spectrum(w));
wout = combine_d1d_spectrum (w, wtemp);
