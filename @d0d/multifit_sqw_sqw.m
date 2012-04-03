function [wout, fitdata] = multifit_sqw_sqw(win, varargin)
% Simultaneously fits a model for S(Q,w) to an array of sqw objects, with background
% functions (which are also S(Q,w) models, varying independently for each sqw object. 
%
% For full help, read documentation for sqw object  multifit_sqw:
%   >> help sqw/multifit_sqw_sqw
%
% Simultaneously fit several objects to a given function:
%   >> [wout, fitdata] = multifit_sqw_sqw (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = multifit_sqw_sqw (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = multifit_sqw_sqw (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per object
%   >> [wout, fitdata] = multifit_sqw_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit_sqw_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit_sqw_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit_sqw_sqw (..., keyword, value, ...)
%
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%       'evaluate'  evaluate function at initial parameter values only, with argument check as well
%       'chisqr'    evaluate chi-squared at the initial parameter values (ignored if 'evaluate' not set)
%
%       'average'   if sqw object, then compute the function at the average h,k,l,e of the pixels in a bin
%
%
%   Example:
%   >> [wout, fitdata] = multifit_sqw (..., 'keep', xkeep, 'list', 0)


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

[wout, fitdata] = multifit_sqw_sqw(sqw(win), varargin{:});
wout=dnd(wout);
