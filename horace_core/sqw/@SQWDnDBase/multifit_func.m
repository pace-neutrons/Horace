function varargout = multifit_func (varargin)
% Simultaneously fit function(s) to one or more sqw objects
%
%   >> myobj = multifit_func (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details about how to do this  <a href="matlab:help('mfclass_Horace');">Click here</a>
%
% For example:
%
%   >> myobj = multifit_func (w1, w2, ...); % set the data
%       :
%   >> myobj = myobj.set_fun (@function_name, pars);  % set forgraound function(s)
%   >> myobj = myobj.set_bfun (@function_name, pars); % set background function(s)
%       :
%   >> myobj = myobj.set_free (pfree);      % set which parameters are floating
%   >> myobj = myobj.set_bfree (bpfree);    % set which parameters are floating
%   >> [wfit,fitpars] = myobj.fit;          % perform fit
%
% This method fits function(s) of the plot axes for both the foreground and
% the background function(s). The format of the fit functions depends on
% the number of plot axes for each sqw object. For examples see:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
% <a href="matlab:edit('example_2d_function');">example_2d_function</a>
% <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
% See also multifit_sqw multifit_sqw_sqw
%
%
%

%-------------------------------------------------------------------------------
% <#doc_def:>
%   class_name = 'SQW'
%   method_name = 'multifit_func'
%   mfclass_name = 'mfclass_Horace'
%   function_tag = ''
%
%
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   sqw_doc = fullfile(fileparts(which('mfclass_Horace')),'_docify')
%
%   doc_multifit_header = fullfile(multifit_doc,'doc_multifit_header.m')
%   doc_fit_functions = fullfile(sqw_doc,'doc_multifit_fit_functions_for_sqw.m')
%
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_multifit_header>  <class_name>  <method_name>  <mfclass_name>  <function_tag>
%
%   <#file:>  <doc_fit_functions>
%
% See also multifit_sqw multifit_sqw_sqw
%
% <#doc_end:>
%-------------------------------------------------------------------------------

mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
varargout{1} = mfclass_Horace (varargin{:}, class(varargin{1}), mf_init);

end
