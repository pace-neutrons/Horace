function [x_out, ok, mess] = testBin_boundaries_from_descriptor (xbounds, x_in, use_mex, force_mex)
% Get new x bin boundaries from a bin boundary descriptor -- public for unit tests

[x_out, ok, mess]=bin_boundaries_from_descriptor (xbounds, x_in, use_mex, force_mex);