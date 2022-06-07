function [wout, fitdata, ok, mess] = multifit_legacy(varargin)
%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Simultaneously fits a function to several datasets, with optional',...
%                 '% background functions.'}
%   main = true;
%   method = false;
%   synonymous = false;
%
%   multifit=true;
%   func_prefix='multifit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%
%   custom_keywords = false;
%
% <#doc_beg:> multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_multifit_short.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_multifit_long.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_multifit_examples_1d.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)

error('HERBERT:multifit_legacy:deprecated', 'This routine has been deprecated and should no longer be used. See: multifit')
[ok,mess,wout,fitdata] = multifit_gateway_main (varargin{:});
if ~ok && nargout<3
    error(mess)
end

