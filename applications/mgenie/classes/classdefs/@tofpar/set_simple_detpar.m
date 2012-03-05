function w = set_simple_detpar(w, delta, x2, twotheta, azimuth)
% Set detector parameters in a tofpar without checking consistency - for fast setting. Use carefully!
%
%   >> w = set_simple(w, delta, x2, twotheta, azimuth)

w.delta=delta;
w.x2=x2;
w.twotheta=twotheta;
w.azimuth=azimuth;
