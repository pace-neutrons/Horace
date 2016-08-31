function mf_object = tobyfit2 (varargin)
% Simultaneously fits a resolution broadened S(Q,w) models to sqw objects.
% Allows for optional background functions.
%
%   >> myobj = tobyfit2 (w1, w2, ...)      % w1, w2 arrays of objects
%
% Type >> doc mfclass   for how to set the fit function, initial
% parameter values, fix parameters, and fit or simulate the data.

mf_init = mfclass_wrapfun ('sqw', @resol_conv_tobyfit_mc,[], @func_eval,[]);
mf_object = mfclass_tobyfit (mf_init, varargin{:});
