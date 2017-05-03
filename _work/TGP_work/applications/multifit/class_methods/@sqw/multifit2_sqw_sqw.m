function mf_object = multifit2_sqw_sqw (varargin)
% Simultaneously fit function(s) of S(Q,w) to one or more sqw objects
%
%   >> myobj = multifit2_sqw (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace_sqw_sqw with the
% provided data, which can then be manipulated to add further data, set the
% fitting functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_Horace_sqw_sqw');">Click here</a>
%
% This method fits function(s) of S(Q,w) as both the foreground and
% the background function(s). For the format of the fit functions:
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_background');">Click here</a> (Background)
%
% See also multifit2 multifit2_sqw


mf_init = mfclass_wrapfun (@sqw_eval, [], @sqw_eval, []);
mf_object = mfclass_Horace_sqw_sqw (varargin{:}, 'sqw', mf_init);
