% Generic header to multifit methods
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%       class_name   = '#1'     % e.g. 'sqw'
%       method_name  = '#2'     % e.g. 'multifit_sqw'
%       mfclass_name = '#3'     % e.g. 'mfclass_Horace_sqw'
%       function_tag = '#4'     % e.g. 'of S(Q,w) '
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Simultaneously fit function(s) <function_tag>to one or more <class_name> objects
%
%   >> myobj = <method_name> (w1, w2, ...)      % w1, w2 objects or arrays of objects
%
% This creates a fitting object of class <mfclass_name> with the provided data,
% which can then be manipulated to add further data, set the fitting
% functions, initial parameter values etc. and fit or simulate the data.
%
% For example:
%
%   >> myobj = <method_name> (w1, w2, ...); % set the data
%       :
%   >> myobj = myobj.set_fun (@function_name, pars);  % set forgraound function(s)
%   >> myobj = myobj.set_bfun (@function_name, pars); % set background function(s)
%       :
%   >> myobj = myobj.set_free (pfree);      % set which parameters are floating
%   >> myobj = myobj.set_bfree (bpfree);    % set which parameters are floating
%   >> [wfit,fitpars] = myobj.fit;          % perform fit
%
% For details <a href="matlab:help('<mfclass_name>');">Click here</a>
