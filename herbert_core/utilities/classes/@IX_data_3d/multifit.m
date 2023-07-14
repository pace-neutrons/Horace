function varargout = multifit (varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   class_name = 'IX_dataset_3d'
%   method_name = 'multifit'
%   mfclass_name = 'mfclass_IX_dataset_3d'
%   function_tag = ''
%
%
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   IX_dataset_doc = fullfile(fileparts(which('mfclass_IX_dataset_1d')),'_docify')
%
%   doc_multifit_header = fullfile(multifit_doc,'doc_multifit_header.m')
%   doc_fit_functions = fullfile(IX_dataset_doc,'doc_multifit_fit_functions.m')
%
%-------------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_multifit_header>  <class_name>  <method_name>  <mfclass_name>  <function_tag>
%
%   <#file:>  <doc_fit_functions>  example_3d_function
%
% <#doc_end:>
%-------------------------------------------------------------------------------


mf_init = mfclass_wrapfun (@func_eval, [], @func_eval, []);
varargout{1} = mfclass_IX_dataset_3d (varargin{:}, 'IX_dataset_3d', mf_init);

end
