function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from sqw object, and a logical array of which values to ignore
% 
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

s = w.data.s;
var = w.data.e;
mask_null = logical(w.data.npix); 
