function mf_object = multifit2_sqw (varargin)
% Simultaneously fit function(s) of S(Q,w) to one or more d1d objects
%
%   >> myobj = multifit2_sqw (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_sqw');">Click here</a>
%
% This method fits model(s) for S(Q,w) as the foreground function(s), and 
% function(s) of the plot axes as the background function(s)
%
% For the format of foreground fit functions:
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_background');">Click here</a> (Background)
%
% For the format of background fit functions:
% <a href="matlab:doc('example_1d_function');">Click here</a>


mf_init = mfclass_wrapfun ('d1d', @sqw_eval, [], @func_eval, []);
mf_object = mfclass (mf_init, varargin{:});
