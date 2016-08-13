function mf_object = multifit2 (varargin)
% Simultaneously fits a function to arrays of sqw objects
%
%   >> myobj = multifit2 (w1, w2, ...)      % w1, w2 arrays of objects
%
% Type >> doc mfclass   for how to set the fit fuinction, initial
% parameter values, fix parameters, and fit or simulate the data.

mf_init = mfcustom ('sqw',@func_eval,[],@func_eval,[]);
mf_object = mfclass(mf_init,varargin{:});
