function mf_object = multifit2_sqw (varargin)
% Simultaneously fit function(s) of S(Q,w) to one or more sqw objects
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
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
%
% The format of the background fit functions depends on the mnumber of plot
% axes for each sqw object. For examples:
% <a href="matlab:doc('example_1d_function');">Click here</a> (1D example)
% <a href="matlab:doc('example_2d_function');">Click here</a> (2D example)
% <a href="matlab:doc('example_3d_function');">Click here</a> (3D example)
%
% See also multifit2 multifit2_sqw_sqw


mf_init = mfclass_wrapfun (@sqw_eval, [], @func_eval, []);
mf_object = mfclass_Horace_sqw (varargin{:}, 'sqw', mf_init);
