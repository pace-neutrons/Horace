function mf_object = multifit2_sqw (varargin)
% Simultaneously fits sqw models on function backgrounds to sqw objects
%
%   >> myobj = multifit2_sqw (w1, w2, ...)      % w1, w2 arrays of objects
%
% Type >> doc mfclass   for how to set the fit function, initial
% parameter values, fix parameters, and fit or simulate the data.

mf_init = mfclass_wrapfun ('sqw', @sqw_eval, [], @func_eval, []);
mf_object = mfclass_sqw (mf_init, varargin{:});
