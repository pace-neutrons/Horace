function [wout, fitdata, ok, mess] = fit_sqw_sqw(win, varargin)
% *** Deprecated function ***
%   This function is no longer maintained. It is strongly recommended
%   that you use multifit_sqw_sqw instead. For more information about multifit_sqw_sqw
%   <a href="matlab:help('d2d/multifit_sqw_sqw');">click here</a>.
%
%   Help for the legacy operation can be <a href="matlab:help('d2d/fit_legacy_sqw_sqw');">found here</a>]

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   doc_deprecated_fit = fullfile(multifit_doc,'doc_deprecated_fit.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_deprecated_fit>  d2d/  _sqw_sqw
% <#doc_end:>
%-------------------------------------------------------------------------------


[wout,fitdata,ok,mess] = fit_legacy_sqw_sqw(win, varargin{:});
