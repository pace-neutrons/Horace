function [wout, fitdata] = fit(win, func_handle, pin, varargin)
% Fits a function to 4D dataset object. If passed an array of 
% objects, then each is fitted independently to the same function.
%
% Syntax:
%   >> [wout, fitdata] = fit(win, func_handle, pin)
%   >> [wout, fitdata] = fit(win, func_handle, pin, pfree)
%   >> [wout, fitdata] = fit(win, func_handle, pin, pfree, keyword, value)
%
%   keyword example:
%   >> [wout, fitdata] = fit(..., 'fit', fcp)
%
% Input:
% ======
%   win     2D dataset object or array of 2D dataset objects to be fitted
%
%   func_handle    
%           Function handle to function to be fitted e.g. @gauss
%           Must have form:
%               y = my_function (x1,x2,... ,xn,p)
%
%            or, more generally:
%               y = my_function (x1,x2,... ,xn,p,c1,c2,...)
%
%               - p         a vector of numeric parameters that can be fitted
%               - c1,c2,... any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%           
%           e.g. Four dimensional Gaussian:
%               function y = gauss(x1,x2,x3,x4,p)
%               y = p(1)*exp(-0.5*((x1-p(2))/p(6)).^2 + (x2-p(3))/p(7)).^2 +...
%                                  (x3-p(4))/p(8)).^2 + (x4-p(5))/p(9)).^2);
%
%   pin     Initial function parameter values [pin(1), pin(2)...]
%            - If the function my_function takes just a numeric array of parameters, p, then this
%             contains the initial values [pin(1), pin(2)...]
%            - If further parameters are needed by my_function, then wrap as a cell array
%               {[pin(1), pin(2)...], c1, c2, ...}  
%
%   pfree   Indicates which are the free parameters in the fit
%           e.g. [1,0,1,0,0] indicates first and third are free
%           Default: all are free
%
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
%   'keep'  Ranges of x and y to retain for fitting. A range is specified by two 
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
%           that were selected for fitting by 'keep', 'remove' and 'mask'.
%           This is useful for plotting the output, as only those points that
%           contributed to the fit will be plotted.
%
%   'all'   Requests that the calculated function be returned over
%           the whole of the domain of the input dataset. If not given, then
%           the function will be returned only at those points of the dataset
%           that contain data.
%
% Output:
% =======
%   wout    2D dataset object containing the evaluation of the function for the
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


% NOTE:
%   If 'all' then npix=ones(size(win.data.s)) to ensure that the plotting is performed
%   Thus lose the npix information.


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

[wout, fitdata] = fit(sqw(win), func_handle, pin, varargin{:});
wout=dnd(wout);

