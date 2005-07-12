function wout = uminus(w1)
% UMINUS  Implement -w for 1D dataset
%
%   >> wout = -w

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

w = -d1d_to_spectrum(w1);
wout = combine_d1d_spectrum (w1, w);