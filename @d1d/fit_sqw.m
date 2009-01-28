function [wout, fitdata] = fit_sqw(win, sqwfunc, pin, varargin)
% Fit model for S(Q,w) to 1D dataset object or array of 1D dataset objects. If passed
% an array of objects, then each is fitted independently to the same function.
%
% Syntax:
%   >> [wout, fitdata] = fit_sqw(win, sqwfunc, pin)
%   >> [wout, fitdata] = fit_sqw(win, sqwfunc, pin, pfree)
%   >> [wout, fitdata] = fit_sqw(win, sqwfunc, pin, pfree, pbind)
%   >> [wout, fitdata] = fit_sqw(..., keyword, value)
%
%   keyword example:
%   >> [yout, fitdata] = fit(..., 'fit', fcp)
%
% Input:
% ======
%   win     1D dataset object or array of 1D dataset objects to be fitted
%
%   sqwfunc Handle to function that calculates S(Q,w)
%           Most commonly used form is:
%               weight = sqwfunc (qh,qk,ql,en,p)
%           where
%               qh,qk,ql,en Arrays containing the coordinates of a set of points
%               p           Vector of parameters needed by dispersion function 
%                          e.g. [A,js,gam] as intensity, exchange, lifetime
%               weight      Array containing calculated energies; if more than
%                          one dispersion relation, then a cell array of arrays
%
%           More general form is:
%               weight = sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%             where
%               p           Typically a vector of parameters that we might want 
%                          to fit in a least-squares algorithm
%               c1,c2,...   Other constant parameters e.g. file name for look-up
%                          table
%
%   pin     Arguments needed by the function. Most commonly, a vector of parameter
%           values e.g. [A,js,gam] as intensity, exchange, lifetime. If a more general
%           set of parameters is required by the function, then
%           package these into a cell array and pass that as pars. In the example
%           above then pars = {p, c1, c2, ...}
%
%   pfree   [Optional] Indicates which are the free parameters in the fit
%           e.g. [1,0,1,0,0] indicates first and third are free
%           Default: all are free
%
%
%   pbind   [Optional] Cell array that indicates which of the free parameters are bound to other parameters
%           in a fixed ratio determined by the initial parameter values contained in pin:
%             pbind={1,3}               parameter 1 is bound to parameter 3.
%             pbind={{1,3},{4,3},{5,6}} parameter 1 bound to 3, 4 bound to 3, and 5 bound to 6
%                                       In this case, parmaeters 1,3,4,5,6 must all be free in pfree.
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,0,7.4)         parameter 1 is bound to parameter 3, ratio 7.4 (the extra '0' is required)
%             pbind={{1,3,0,7.4},{4,3,0,0.023},{5,6}}
%
%   Optional keywords:
%   ------------------
%   'list'  Numeric code to control output to Matlab command window to monitor
%           status of fit
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
%   'fit'   Array of fit control parameters
%           fcp(1)  relative step length for calculation of partial derivatives
%           fcp(2)  maximum number of iterations
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if chisqr_new-chisqr_old < fcp(3)*chisqr_old
%
%   'keep'  Ranges of data to retain for fitting. A range is specified by two 
%           pairs of numbers which define a rectangle:
%               [xlo, xhi, ylo, yhi]
%           Several ranges can be defined by making an (m x 4) array:
%               [xlo(1), xhi(1), ylo(1), yhi(1); xlo(2), xhi(2), ylo(2), yhi(2); ...]
%
%  'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%
%   'mask'  Array of ones and zeros, with the same number of elements as the data
%           array, that indicates which of the data points are to be retained for
%           fitting
%
%  'select' Calculates the returned function values, yout, only at the points
%           that were selected for fitting by 'keep' and 'remove'; all other
%           points are set to NaN. This is useful for plotting the output, as
%           only those points that contributed to the fit will be plotted.
%
%
% Output:
% =======
%   wout    1D dataset object containing the evaluation of the function for the
%          fitted parameter values.
%
%   fitdata Result of fit for each dataset
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%                                   [if func is mfit function; else named 'p1','p2',...]
%
% EXAMPLES: 
%
% Fit a 2D Gaussian, allowing only height and position to vary:
%   >> ht=100; x0=1; y0=3; sigx=2; sigy=1.5;
%   >> [wfit, fdata] = fit(w, @gauss2d, [ht,x0,y0,sigx,0,sigy], [1,1,1,0,0,0])
%
% Allow all parameters to vary, but remove two rectangles from the data
%   >> ht=100; x0=1; y0=3; sigx=2; sigy=1.5;
%   >> [wfit, fdata] = fit(w, @gauss2d, [ht,x0,y0,sigx,0,sigy], ...
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3])


[wout, fitdata] = fit_sqw(sqw(win), sqwfunc, pin, varargin{:});
wout=dnd(wout);
