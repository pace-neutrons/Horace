function mf_object = multifit2_func (varargin)
% Simultaneously fit function(s) to one or more sqw objects
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
% the number of plot axes for each sqw object. For examples:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
% <a href="matlab:edit('example_2d_function');">example_2d_function</a>
% <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
% Synonymous with method: multifit2
%
% See also multifit2 multifit2_sqw multifit2_sqw_sqw


mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
mf_object = mfclass_Horace (varargin{:}, 'sqw', mf_init);
