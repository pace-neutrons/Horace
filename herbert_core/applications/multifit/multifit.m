function varargout = multifit (varargin)
% Simultaneously fit function(s) to one or more datasets
%
% Single dataset:
%   >> myobj = multifit (x, y, e)
%
% Multiple datsets:
%   >> myobj = multifit (w1, w2, ...)
%
%   w1, w2 can each be:
%   - Structure with fields x, y, e, or array of such structure
%   - Cell array {x,y,e} or cell array of cell arrays {{x1,y1,e1}, {x2,y2,e2},...
%   - Object, or array of objects (note that if multifit2 has been overloaded
%     as a method for the object, then that will be found first)
%
% This creates a fitting object of class mfclass with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
%
% For example:
%
%   >> myobj = multifit_sqw (w1, w2, ...); % set the data
%       :
%   >> myobj = myobj.set_fun (@function_name, pars);  % set forgraound function(s)
%   >> myobj = myobj.set_bfun (@function_name, pars); % set background function(s)
%       :
%   >> myobj = myobj.set_free (pfree);      % set which parameters are floating
%   >> myobj = myobj.set_bfree (bpfree);    % set which parameters are floating
%   >> [wfit,fitpars] = myobj.fit;          % perform fit
%
% For details <a href="matlab:help('mfclass');">Click here</a>
%
% For the format of fit functions (foreground or background), see the examples:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
% <a href="matlab:edit('example_2d_function');">example_2d_function</a>
% <a href="matlab:edit('example_3d_function');">example_3d_function</a>

varargout{1} = mfclass (varargin{:});

end
