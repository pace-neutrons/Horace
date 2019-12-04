function varargout = multifit_sqw (varargin)
% Simultaneously fit function(s) of S(Q,w)to one or more d1d objects
%
%   >> myobj = multifit_sqw (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class mfclass_Horace_sqw with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
% For details about how to do this  <a href="matlab:help('mfclass_Horace_sqw');">Click here</a>
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
% This method fits model(s) for S(Q,w) as the foreground function(s), and
% function(s) of the plot axes for the background function(s)
%
% For the format of foreground fit functions:
% <a href="matlab:edit('example_sqw_spin_waves');">Damped spin waves</a>
% <a href="matlab:edit('example_sqw_flat_mode');">Dispersionless excitations</a>
%
% The format of the background fit functions depends on the number of plot
% axes for each sqw object. For examples see:
% <a href="matlab:edit('example_1d_function');">example_1d_function</a>
% <a href="matlab:edit('example_2d_function');">example_2d_function</a>
% <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
% See also multifit multifit_sqw_sqw
%
%
%
%[Help for legacy use (2017 and earlier):
%   If you are still using the legacy version then it is strongly recommended
%   that you change to the new operation. Help for the legacy operation can
%   be <a href="matlab:help('d1d/multifit_legacy_sqw');">found here</a>]

%-------------------------------------------------------------------------------
% <#doc_def:>
%   class_name = 'd1d'
%   dim = '1'
%   method_name = 'multifit_sqw'
%   method_name_legacy = 'multifit_legacy_sqw'
%   mfclass_name = 'mfclass_Horace_sqw'
%   function_tag = 'of S(Q,w) '
%
%
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   sqw_doc = fullfile(fileparts(which('mfclass_Horace')),'_docify')
%
%   doc_multifit_header = fullfile(multifit_doc,'doc_multifit_header.m')
%   doc_fit_functions = fullfile(sqw_doc,'doc_multifit_sqw_fit_functions_for_dnd.m')
%   doc_multifit_legacy_footnote = fullfile(multifit_doc,'doc_multifit_legacy_footnote.m')
%
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_multifit_header>  <class_name>  <method_name>  <mfclass_name>  <function_tag>
%
%   <#file:>  <doc_fit_functions>  <dim>
%
% See also multifit multifit_sqw_sqw
%
%   <#file:>  <doc_multifit_legacy_footnote>  <class_name>/<method_name_legacy>
% <#doc_end:>
%-------------------------------------------------------------------------------


if ~mfclass.legacy(varargin{:})
    mf_init = mfclass_wrapfun (@sqw_eval, [], @func_eval, []);
    varargout{1} = mfclass_Horace_sqw (varargin{:}, 'd1d', mf_init);
else
    [varargout{1:nargout}] = mfclass.legacy_call (@multifit_legacy_sqw, varargin{:});
end
