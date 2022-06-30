function [wout,fitdata,ok,mess] = fit(varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit')),'_docify')
%   doc_deprecated_fit = fullfile(multifit_doc,'doc_deprecated_fit.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:>  <doc_deprecated_fit>  ''  ''
% <#doc_end:>
%-------------------------------------------------------------------------------


[wout,fitdata,ok,mess] = fit_legacy(varargin{:});
