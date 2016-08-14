function mf_object = multifit2_func (varargin)
% Simultaneously fits functions to d1d objects
%
%   >> myobj = multifit2_func (w1, w2, ...)      % w1, w2 arrays of objects
%
% Type >> doc mfclass   for how to set the fit functions, initial
% parameter values, fix parameters, and fit or simulate the data.
%
% Synonymous with method: multifit2

mf_init = mfclass_wrapfun ('d1d', @func_eval,[], @func_eval,[]);
mf_object = mfclass (mf_init, varargin{:});
