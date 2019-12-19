function [wout, fitdata, ok, mess] = multifit_legacy(win, varargin)
% Simultaneously fits a function to an array of d2d objects, with optional
% background functions.
% Synonymous with d2d method multifit_func
%
% A background function can be added to the fit function.
% If passed an array of datasets, then each dataset is fitted independently.
%
%
% For full help, read the documentation displayed when you type:
%   >> help d2d/multifit_legacy_func
%
%
% Fit several datasets in succession to a given function:
% -------------------------------------------------------
%   >> [wout, fitdata] = multifit_legacy (w, func, pin)
%   >> [wout, fitdata] = multifit_legacy (w, func, pin, pfree)
%   >> [wout, fitdata] = multifit_legacy (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background function added to the function:
% --------------------------------------------------------
%   >> [wout, fitdata] = multifit_legacy (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit_legacy (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit_legacy (..., bkdfunc, bpin, bpfree, bpbind)
%
%
% Additional keywords controlling the fit:
% ----------------------------------------
% You can alter the range of data to fit, alter convergence criteria,
% verbosity of output etc. with keywords, some of which need to be paired
% with input values, some of which are just logical flags:
%
%   >> [wout, fitdata] = multifit_legacy (..., keyword, value, ...)
%
% Keywords that are logical flags (indicated by *) take the value true
% if the keyword is present, or their default if not.
%
%     Select points to fit:
%       'keep'          Range of x values to keep.
%       'remove'        Range of x values to remove.
%       'mask'          Logical mask array (true for those points to keep).
%   *   'select'        If present, calculate output function only at the
%                      points retained for fitting.
%
%     Control fit and output:
%       'fit'           Alter convergence criteria for the fit etc.
%       'list'          Level of verbosity of output during fitting (0,1,2...).
%
%     Evaluate at initial parameters only (i.e. no fitting):
%   *   'evaluate'      Evaluate function at initial parameter values only
%                      without doing a fit. Performs an argument check as well.
%                     [Default: false]
%   *   'foreground'    Evaluate foreground function only (if 'evaluate' is
%                      not set then ignored).
%   *   'background'    Evaluate background function only (if 'evaluate' is
%                      not set then ignored).
%   *   'chisqr'        Evaluate chi-squared at the initial parameter values
%                      (ignored if 'evaluate' not set).
%
%     Control if foreground and background functions are global or local:
%   *   'global_foreground' Foreground function applies to all datasets
%                          [Default: true]
%   *   'local_foreground'  Foreground function(s) apply to each dataset
%                          independently [Default: false]
%   *   'local_background'  Background function(s) apply to each dataset
%                          independently [Default: true]
%   *   'global_background' Background function applies to all datasets
%                          [Default: false]
%
%   EXAMPLES:
%   >> [wout, fitdata] = multifit_legacy(...,'keep',[0.4,1.8],'list',2)
%
%   >> [wout, fitdata] = multifit_legacy(...,'select')
%
% If unable to fit, then the program will halt and display an error message.
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = multifit_legacy (...)

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Simultaneously fits a function to an array of d2d objects, with optional',...
%                 '% background functions.',...
%                 '% Synonymous with d2d method multifit_func'};
%   main = false;
%   method = true;
%   synonymous = true;
%
%   multifit=true;
%   func_prefix='multifit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%   obj_name = 'd2d'
%
%   full_help = 'd2d/multifit_legacy_func'
%
%   custom_keywords = false;
%
% <#doc_beg:> multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_fit_short.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargout<3
    [wout,fitdata]=multifit_func(sqw(win), varargin{:});  % forces failure if there is an error, as is the convention for fit when no ok argument
else
    [wout,fitdata,ok,mess]=multifit_func(sqw(win), varargin{:});
end
wout=dnd(wout);

