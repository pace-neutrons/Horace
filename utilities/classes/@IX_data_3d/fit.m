function [wout, fitdata, ok, mess] = fit(win, varargin)
% *** Deprecated function ***
%   This function is no longer maintained. It is strongly recommended
%   that you use multifit instead. For more information about multifit
%   <a href="matlab:help('IX_dataset_3d/multifit');">click here</a>.
%
%   Help for the legacy operation can be <a href="matlab:help('IX_dataset_3d/fit_legacy');">found here</a>]

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   doc_deprecated_fit = fullfile(multifit_doc,'doc_deprecated_fit.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_deprecated_fit>  IX_dataset_3d/  ''
% <#doc_end:>
%-------------------------------------------------------------------------------


[wout,fitdata,ok,mess] = fit_legacy(win, varargin{:});
