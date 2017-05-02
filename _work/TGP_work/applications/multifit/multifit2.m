function mf_object = multifit2 (varargin)
% Simultaneously fit function(s) to one or more datasets
%
% Single dataset:
%   >> myobj = multifit2 (x, y, e)
%
% Multiple datsets:
%   >> myobj = multifit2 (w1, w2, ...)      
%
%   w1, w2 can each be:
%   - Structure with fields x, y, z, or array of such structure
%   - Cell array {x,y,e} or cell array of cell arrays {{x1,y1,e1}, {x2,y2,e2},...
%   - Object, or array of objects (note that if multifit2 has been overloaded
%     as a method for the object, then that will be found first)
%
% This creates a fitting object of class mfclass with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details <a href="matlab:doc('mfclass');">Click here</a>
%
% For the format of fit functions (foreground or background):
% <a href="matlab:doc('example_1d_function');">Click here</a>


% Synonymn for mfclass for consistency with previous use of multifit
   
mf_object = mfclass (varargin{:});
