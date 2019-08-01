% Define the following:
% ---------------------
%   multifit        logical     True if multifit, false if just fit
%   func_prefix     string      'multifit' or 'fit' generally
%   func_suffix     string      Suffix to function e.g. '_sqw'
%   custom_keywords logical     True if additional keywords for this
%                               instance of multifit
%   doc_custom_keywords_short
%                   string      Name of file with short documentation of the
%                               custom keywords


<#doc_beg:>
% Additional keywords controlling the fit:
% ----------------------------------------
% You can alter the range of data to fit, alter convergence criteria,
% verbosity of output etc. with keywords, some of which need to be paired
% with input values, some of which are just logical flags:
%
%   >> [wout, fitdata] = <func_prefix><func_suffix> (..., keyword, value, ...)
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
<MULTIFIT:>
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
<MULTIFIT/END:>
<CUSTOM_KEYWORDS:>
%     Special keyword(s):
    <#FILE:> <doc_custom_keywords_short>
%
<CUSTOM_KEYWORDS/END:>
%   EXAMPLES:
%   >> [wout, fitdata] = <func_prefix><func_suffix>(...,'keep',[0.4,1.8],'list',2)
%
%   >> [wout, fitdata] = <func_prefix><func_suffix>(...,'select')
