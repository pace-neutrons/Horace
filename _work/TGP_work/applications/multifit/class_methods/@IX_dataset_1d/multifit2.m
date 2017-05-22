function mf_object = multifit2 (varargin)
% Simultaneously fit function(s) to one or more IX_dataset_1d objects
%
%   >> myobj = multifit2 (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_IX_dataset_1d with the provided
% data, which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass_IX_dataset_1d');">Click here</a>
%
% For the format of fit functions (foreground or background):
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
   
mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
mf_object = mfclass_IX_dataset_1d (varargin{:}, 'IX_dataset_1d', mf_init);
