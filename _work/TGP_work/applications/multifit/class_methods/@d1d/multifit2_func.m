function mf_object = multifit2_func (varargin)
% Simultaneously fit function(s) to one or more d1d objects
%
%   >> myobj = multifit2 (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_sqw');">Click here</a>
%
% This method fits function(s) of the plot axes as both the foreground and
% the background function(s). For the format of the fit functions:
% <a href="matlab:doc('example_1d_function');">Click here</a>
%
% Synonymous with method: multifit2

mf_init = mfclass_wrapfun ('d1d', @func_eval, [], @func_eval, []);
mf_object = mfclass (mf_init, varargin{:});
