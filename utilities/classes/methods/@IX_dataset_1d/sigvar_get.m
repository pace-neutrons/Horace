function [s,var,msk] = sigvar_get (w)
% Get signal and variance from object, and a logical array of which values to keep
% 
%   >> [s,var,msk] = sigvar_get (w)

% Original author: T.G.Perring

s = w.signal;
var = (w.error).^2;
msk = true(size(s));
