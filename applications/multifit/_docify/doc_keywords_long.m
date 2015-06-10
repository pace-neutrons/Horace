% Define the following:
% ---------------------
%   multifit        logical     True if multifit, false if just fit
%   func_prefix     string      'multifit' or 'fit'
%   func_suffix     string      Suffix to function e.g. '_sqw'
%   keywords        cellstr     Additional keywords


<#doc_beg:>
% Optional keywords:
% ------------------
% Keywords that are logical flags (indicated by *) take the value true
% if the keyword is present, or their default if not.
%
% Select points to fit:
%   'keep'  Array giving ranges along each x-axis to retain for fitting.
%           - If one dimension:
%               [xlo, xhi]
%           - If two dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi]
%           - General case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range to keep can be specified in additional rows:
%               [Range_1; Range_2; Range_3;...; Range_m]
%           where each of the ranges are given in the format above.
%
<MULTIFIT:>
%           If fitting an array of datasets: then 'keep' applies to all
%           datasets.
%
%           Alternatively, give a cell array of arrays, one per data set
%           to specify different ranges to keep for each dataset.
<MULTIFIT/END:>
%
%   'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. 'remove' takes precedence over 'keep'.
%
%   'mask'  Array of ones and zeros, with the same number of elements as the
%           input data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting (1=keep, 0=remove).
%
<MULTIFIT:>
%           If fitting an array of datasets: then the mask array applies to
%           all datasets.
%
%           Alternatively, give a cell array of mask arrays, one per data set
%           to specify different masks for each dataset.
<MULTIFIT/END:>
%
% * 'select' Calculates the returned function values only at the points
%           that were selected for fitting by 'keep', 'remove', 'mask' (and
%           which were not eliminated for having zero error bar). This is
%           useful for plotting the output, as only those points that
%           contributed to the fit will be plotted. [Default: false]
%
% Control fit and output:
%   'fit'   Array of fit control parameters
%           fcp(1)  Relative step length for calculation of partial derivatives
%                   [Default: 1e-4]
%           fcp(2)  Maximum number of iterations [Default: 20]
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if (chisqr_new-chisqr_old) < fcp(3)*chisqr_old
%                   [Default: 1e-3]
%
%   'list'  Numeric code to control output to Matlab command window to monitor
%           status of fit:
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
% Evaluate at initial parameters only (i.e. no fitting):
% * 'evaluate'    Evaluate the fitting function at the initial parameter values
%                without doing a fit. Useful for checking the goodness of
%                starting parameters. Performs an argument check as well.
%                By default, then sum of the foreground and background
%                functions is calculated. [Default: false]
% * 'foreground'  Evaluate foreground function only (if 'evaluate' is
%                not set then ignored).
% * 'background'  Evaluate background function only (if 'evaluate' is
%                not set then ignored).
% * 'chisqr'      Evaluate chi-squared at the initial parameter values
%               (ignored if 'evaluate' not set).
%
<MULTIFIT:>
% Control if foreground and background functions are global or local:
% * 'global_foreground' Foreground function applies to all datasets
%                      [Default: true]
% * 'local_foreground'  Foreground function(s) apply to each dataset
%                      independently [Default: false]
% * 'local_background'  Background function(s) apply to each dataset
%                      independently [Default: true]
% * 'global_background' Background function applies to all datasets
%                      [Default: false]
<MULTIFIT/END:>
%<keywords>
%
%   Example:
%   >> [wout, fitdata] = <func_prefix><func_suffix>(...,'keep',[0.4,1.8],'list',2)
%
%