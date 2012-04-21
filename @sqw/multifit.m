function [wout, fitdata, ok, mess] = multifit(win, varargin)
% Simultaneously fit a function to an array of sqw objects.
% Optionally allows background functions that vary independently for each sqw object. 
%
% Synonymous with multifit_func. For full help, read documentation for multifit_func:
%   >> help sqw/multifit_func
%
% Simultaneously fit several objects to a given function:
%   >> [wout, fitdata] = multifit (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = multifit (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = multifit (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per object
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin, bpfree, bpbind)
%
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit, call with additional arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = multifit (...)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit (..., keyword, value, ...)
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
%   Example:
%   >> [wout, fitdata] = multifit (..., 'keep', xkeep, 'list', 0)


if nargout<3
    [wout,fitdata]=multifit_func(win, varargin{:});  % forces failure if there is an error, as is the convention for fit when no ok argument
else
    [wout,fitdata,ok,mess]=multifit_func(win, varargin{:});
end
