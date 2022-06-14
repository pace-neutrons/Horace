function [ok,mess,varargout] = multifit_gateway_main (varargin)
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
%--------------------------------------------------------------------------
% The documentation for the public multifit application is reproduced below.
% This is the gateway to the master multifit function, and its arguments
% differs as follows:
%
% - The output arguments are in a different order, although the input
%   arguments are the same;
% - There is an additional keyword argument which although visible from the
%   public multifit is not advertised because it is meant only for
%   developers.
%
% In full:
%
%   >> [ok,mess,wout,fitdata] = multifit_main(x,y,e,...)
%   >> [ok,mess,wour,fitdata] = multifit_main(w,...)
%
%
% Input:
% ======
% Input arguments are exactly the same as for the public multifit
% application.
%
%
% Optional keyword:
% -----------------
%   'init_func'   Function handle: if not empty then apply a pre-processing
%                function to the data before least squares fitting.
%                 The purpose of this function is to allow pre-computation
%                of quantities that speed up the evaluation of the fitting
%                function. It must have the form:
%
%                   [ok,mess,c1,c2,...] = my_init_func(w)   % create c1,c2,...
%                   [ok,mess,c1,c2,...] = my_init_func()    % recover stored
%                                                           % c1,c2,...
%
%                where
%                   w       Cell array, where each element is either
%                           - an x-y-e triple with w(i).x a cell array of
%                             arrays, one for each x-coordinate
%                           - a scalar object
%
%                   ok      True if the pre-processed output c1, c2... was
%                          computed correctly; false otherwise
%
%                   mess    Error message if ok==false; empty string
%                          otherwise
%
%                   c1,c2,..Output e.g. lookup tables that can be
%                          pre-computed from the data w
%
%
% Output:
% =======
% Output arguments are the same as the public multifit application, but the
% order is changed from [wout,fitdata,ok,mess] ot [ok,mess,wout,fitdata]
%--------------------------------------------------------------------------
%
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


[ok,mess,parsing,output]=multifit_main(varargin{:},'noparsefunc_');
nout=nargout-2;
varargout(1:nout)=output(1:nout);   % appears to work even if nout<=0
