function mf_object = multifit2_func (varargin)
% Simultaneously fit function(s) to one or more d1d objects
%
%   >> myobj = multifit2 (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_Horace');">Click here</a>
%
% This method fits function(s) of the plot axes for both the foreground and
% the background function(s). The format of the fit functions depends on 
% the mnumber of plot axes for each sqw object. For examples:
% <a href="matlab:doc('example_1d_function');">Click here</a> (1D example)
% <a href="matlab:doc('example_2d_function');">Click here</a> (2D example)
% <a href="matlab:doc('example_3d_function');">Click here</a> (3D example)
%
% Synonymous with method: multifit2
%
% See also multifit2 multifit2_sqw multifit2_sqw_sqw


mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
mf_object = mfclass_Horace (varargin{:}, 'd1d', mf_init);
