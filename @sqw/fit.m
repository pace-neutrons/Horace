function [wout, fitdata, ok, mess] = fit(win, varargin)
% Fits a function to an sqw object, with an optional background function.
% If passed an array of sqw objects, then each object is fitted independently.
%
% Synonymous with fit_func. For full help, read documentation for fit_func:
%   >> help sqw/fit_func
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
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit, call with additional arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = fit (...)
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
%       'evaluate'  evaluate function at initial parameter values only, with argument check as well
%       'chisqr'    evaluate chi-squared at the initial parameter values (ignored if 'evaluate' not set)
%
%   Example:
%   >> [wout, fitdata] = fit (..., 'keep', xkeep, 'list', 0)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if nargout<3
    [wout,fitdata]=fit_func(win, varargin{:});  % forces failure if there is an error, as is the convention for fit when no ok argument
else
    [wout,fitdata,ok,mess]=fit_func(win, varargin{:});
end
