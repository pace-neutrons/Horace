function [wout, fitdata] = fit(win, varargin)
% Fits a function to an sqw object. If passed an array of 
% sqw objects, then each is fitted independently to the same function.
%
% Synonymous with fit_func. Please type >> help fit_func for full help.
%
% Differs from multifit_func, which fits all objects in the array simultaneously
% but with independent backgrounds.
%
% Fit several objects in succession to a given function:
%   >> [wout, fitdata] = fit (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = fit (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = fit (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' function added to the function
%   >> [wout, fitdata] = fit (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = fit (..., keyword, value, ...)
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%
%   Example:
%   >> [wout, fitdata] = fit (..., 'keep', xkeep, 'list', 0)
%


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


[wout, fitdata] = fit_func(win, varargin{:});
