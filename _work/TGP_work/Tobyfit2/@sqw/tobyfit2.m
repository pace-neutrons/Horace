function mf_object = tobyfit2 (varargin)
% Simultaneously fits resolution broadened S(Q,w) models to sqw objects.
% Allows for optional background functions.
%
%   >> myobj = tobyfit2 (w1, w2, ...)      % w1, w2 arrays of objects
%
% This creates a fitting object of class mfclass_tobyfit with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_tobyfit');">Click here</a>
%
% This method fits model(s) for S(Q,w) as the foreground function(s), and 
% function(s) of the plot axes as the background function(s)
%
% For the format of foreground fit functions:
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_background');">Click here</a> (Background)
%
% For the format of background fit functions:
% <a href="matlab:doc('example_1d_function');">Click here</a> (1D example)
% <a href="matlab:doc('example_2d_function');">Click here</a> (2D example)


% Initialise
mf_init = mfclass_wrapfun ('sqw', @resol_conv_tobyfit_mc, [], @func_eval, [],...
    true, false, @resol_conv_tobyfit_mc_init, []);

% Construct
mf_object = mfclass_tobyfit (mf_init, varargin{:});
