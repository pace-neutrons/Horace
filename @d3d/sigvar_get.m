function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from object, and a logical array of which values to ignore
% 
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

s = w.s;
var = w.e;
mask_null = logical(w.npix);
