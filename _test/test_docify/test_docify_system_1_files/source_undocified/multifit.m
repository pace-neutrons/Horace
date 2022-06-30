function [wout, fitdata, ok, mess] = multifit(varargin)
% <#doc_def:>
%   first_line = {'% Simultaneously fits a function to several datasets, with optional',...
%                 '% background functions.'}
%   main = true;
%   method = false;
%   synonymous = false;
%
%   multifit=true;
%   func_prefix='multifit';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%
%   custom_keywords = false;
%
% <#doc_beg:>
%   <#file:> meta_docs:::doc_multifit_short.m
%
%
%   <#file:> meta_docs:::doc_multifit_long.m
%
%
%   <#file:> meta_docs:::doc_multifit_examples_1d.m
% <#doc_end:>


% Original author: T.G.Perring
%


[ok,mess,wout,fitdata] = multifit_gateway_main (varargin{:});
if ~ok && nargout<3
    error(mess)
end
