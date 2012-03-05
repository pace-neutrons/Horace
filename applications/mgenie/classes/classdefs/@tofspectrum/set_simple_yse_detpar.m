function w = set_simple_yse_detpar (w, y, s, e, delta, x2, twotheta, azimuth)
% Special function for changing components of a tofspectrum needed by data reading routine(s)
%
%   >> w = set_simple_yse_detpar (w, y, s, e, delta, x2, twotheta, azimuth)
%
% Uses fast 'set' routines that do not check the arguments going in - so use carefully!

w.IX_dataset_2d=set_simple_yse(w.IX_dataset_2d,y,s,e);
w.tofpar=set_simple_detpar(w.tofpar,delta,x2,twotheta,azimuth);
