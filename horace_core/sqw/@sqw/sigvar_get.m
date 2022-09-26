function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from object, and a logical array of which values to ignore
%
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
[s,var,mask_null] = sigvar_get(w.data_);
