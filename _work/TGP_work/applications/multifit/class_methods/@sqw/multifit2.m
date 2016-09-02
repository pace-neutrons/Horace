function mf_object = multifit2 (varargin)
% Simultaneously fits functions to sqw objects
%
%   >> myobj = multifit2 (w1, w2, ...)      % w1, w2 arrays of objects
%
% Type >> doc mfclass   for how to set the fit functions, initial
% parameter values, fix parameters, and fit or simulate the data.

mf_init = mfclass_wrapfun ('sqw', @func_eval, [], @func_eval, []);
mf_object = mfclass_sqw (mf_init, varargin{:});
