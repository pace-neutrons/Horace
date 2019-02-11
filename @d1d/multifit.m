function varargout = multifit (varargin)
% Simultaneously fit function(s) to one or more d1d objects
%
%   >> myobj = multifit (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details about how to do this  <a href="matlab:help('mfclass_Horace');">Click here</a>
%
% For example:
%
%   >> myobj = multifit (w1, w2, ...); % set the data
%       :
%   >> myobj = myobj.set_fun (@function_name, pars);  % set forgraound function(s)
%   >> myobj = myobj.set_bfun (@function_name, pars); % set background function(s)
%       :
%   >> myobj = myobj.set_free (pfree);      % set which parameters are floating
%   >> myobj = myobj.set_bfree (bpfree);    % set which parameters are floating
%   >> [wfit,fitpars] = myobj.fit;          % perform fit
%
% This method fits function(s) of the plot axes for both the foreground and
% the background function(s). An example fit function can be found here:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
%
% See also multifit_sqw multifit_sqw_sqw
%
%
%
%[Help for legacy use (2017 and earlier):
%   If you are still using the legacy version then it is strongly recommended
%   that you change to the new operation. Help for the legacy operation can
%   be <a href="matlab:help('d1d/multifit_legacy');">found here</a>]

%-------------------------------------------------------------------------------
% <#doc_def:>
%   class_name = 'd1d'
%   dim = '1'
%   method_name = 'multifit'
%   method_name_legacy = 'multifit_legacy'
%   mfclass_name = 'mfclass_Horace'
%   function_tag = ''
%
%
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   sqw_doc = fullfile(fileparts(which('mfclass_Horace')),'_docify')
%
%   doc_multifit_header = fullfile(multifit_doc,'doc_multifit_header.m')
%   doc_fit_functions = fullfile(sqw_doc,'doc_multifit_fit_functions_for_dnd.m')
%   doc_multifit_legacy_footnote = fullfile(multifit_doc,'doc_multifit_legacy_footnote.m')
%
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_multifit_header>  <class_name>  <method_name>  <mfclass_name>  <function_tag>
%
%   <#file:>  <doc_fit_functions>  <dim>
%
% See also multifit_sqw multifit_sqw_sqw
%
%   <#file:>  <doc_multifit_legacy_footnote>  <class_name>/<method_name_legacy>
% <#doc_end:>
%-------------------------------------------------------------------------------


if ~mfclass.legacy(varargin{:})
    mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
    varargout{1} = mfclass_Horace (varargin{:}, 'd1d', mf_init);
else
    [varargout{1:nargout}] = mfclass.legacy_call (@multifit_legacy, varargin{:});
end
