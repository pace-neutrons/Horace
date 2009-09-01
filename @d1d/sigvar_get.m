function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from object, and a logical array of which values to ignore
% 
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

s = w.s;
var = w.e;
mask_null = logical(w.npix);
