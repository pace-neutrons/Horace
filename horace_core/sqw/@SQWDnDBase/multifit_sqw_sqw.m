function varargout = multifit_sqw_sqw (varargin)
% Simultaneously fit function(s) of S(Q,w)to one or more sqw objects
%
%   >> myobj = multifit_sqw_sqw (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace_sqw_sqw with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details about how to do this  <a href="matlab:help('mfclass_Horace_sqw_sqw');">Click here</a>
%
% For example:
%
%   >> myobj = multifit_sqw_sqw (w1, w2, ...); % set the data
%       :
%   >> myobj = myobj.set_fun (@function_name, pars);  % set forgraound function(s)
%   >> myobj = myobj.set_bfun (@function_name, pars); % set background function(s)
%       :
%   >> myobj = myobj.set_free (pfree);      % set which parameters are floating
%   >> myobj = myobj.set_bfree (bpfree);    % set which parameters are floating
%   >> [wfit,fitpars] = myobj.fit;          % perform fit
%
% This method fits function(s) of S(Q,w) as both the foreground and
% the background function(s). For the format of the fit functions:
% <a href="matlab:edit('example_sqw_spin_waves');">Damped spin waves</a>
% <a href="matlab:edit('example_sqw_flat_mode');">Dispersionless excitations</a>
%
% See also multifit multifit_sqw
%
%
%
%-------------------------------------------------------------------------------
% <#doc_def:>
%   class_name = 'SQWDnDBase'
%   method_name = 'multifit_sqw_sqw'
%   mfclass_name = 'mfclass_Horace_sqw_sqw'
%   function_tag = 'of S(Q,w) '
%
%
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   sqw_doc = fullfile(fileparts(which('mfclass_Horace')),'_docify')
%
%   doc_multifit_header = fullfile(multifit_doc,'doc_multifit_header.m')
%   doc_fit_functions = fullfile(sqw_doc,'doc_multifit_sqw_sqw_fit_functions_for_sqw.m')
%
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_multifit_header>  <class_name>  <method_name>  <mfclass_name>  <function_tag>
%
%   <#file:>  <doc_fit_functions>
%
% See also multifit multifit_sqw
%
% <#doc_end:>
%-------------------------------------------------------------------------------

mf_init = mfclass_wrapfun (@sqw_eval, [], @sqw_eval, []);
varargout{1} = mfclass_Horace_sqw_sqw (varargin{:}, class(varargin{1}), mf_init);

end
