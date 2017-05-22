function mf_object = multifit2_sqw (varargin)
% Simultaneously fit function(s) of S(Q,w) to one or more d1d objects
%
%   >> myobj = multifit2_sqw (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace_sqw with the provided
% data, which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_Horace_sqw');">Click here</a>
%
% This method fits model(s) for S(Q,w) as the foreground function(s), and
% function(s) of the plot axes for the background function(s)
%
% For the format of foreground fit functions:
% <a href="matlab:edit('example_sqw_spin_waves');">Damped spin waves</a>
% <a href="matlab:edit('example_sqw_flat_mode');">Dispersionless excitations</a>
%
% For the format of background fit functions:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
%
% See also multifit2 multifit2_sqw_sqw


mf_init = mfclass_wrapfun (@sqw_eval, [], @func_eval, []);
mf_object = mfclass_Horace_sqw (varargin{:}, 'd1d', mf_init);
