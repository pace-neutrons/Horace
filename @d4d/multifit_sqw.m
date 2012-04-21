function [wout, fitdata, ok, mess] = multifit_sqw(win, varargin)
% Simultaneously fit a model for S(Q,w) to an array of objects.
% Optionally allows background functions that vary independently for each object. 
%
% For full help, read documentation for sqw object multifit_sqw:
%   >> help sqw/multifit_sqw
%
% Simultaneously fit several objects to a given function:
%   >> [wout, fitdata] = multifit_sqw (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = multifit_sqw (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = multifit_sqw (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per object
%   >> [wout, fitdata] = multifit_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit, call with additional arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = multifit_sqw (...)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit_sqw (..., keyword, value, ...)
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
%   >> [wout, fitdata] = multifit_sqw (..., 'keep', xkeep, 'list', 0)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargout<3
    [wout,fitdata]=multifit_sqw(sqw(win), varargin{:});  % forces failure if there is an error, as is the convention for fit when no ok argument
else
    [wout,fitdata,ok,mess]=multifit_sqw(sqw(win), varargin{:});
end
wout=dnd(wout);
