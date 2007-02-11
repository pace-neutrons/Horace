function [wout, fitdata] = fit(win, sqwfunc, pin, varargin)
% Fitting routine for a 3D dataset. If passed an array of 
% 3D datasets, then each is fitted independently to the same function.
%
% Syntax:
%   >> [yout, fitdata] = fit(win, func, pin)
%   >> [yout, fitdata] = fit(win, func, pin, pfree)
%   >> [yout, fitdata] = fit(win, func, pin, pfree, keyword, value)
%
%   keyword example:
%   >> [yout, fitdata] = fit(..., 'fit', fcp)
%
% Input:
% ======
%   win     3D dataset object or array of 3D dataset objects to be fitted
%
%   sqwfunc Handle of the function to calculate sqw. Function should be of form
%           Must have form:
%               weight = sqwfunc (qh,qk,ql,en,p)
%            where
%               qh,qk,ql,en Arrays containing the coordinates of a set of points
%               p           Vector of parameters needed by dispersion function 
%                          e.g. [A,js,gam] as intensity, exchange, lifetime
%               weight      Array containing calculated energies; if more than
%                          one dispersion relation, then a cell array of arrays
%
%   pin     Initial function parameter values [pin(1), pin(2)...]
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
%           triplets of numbers which define the corners of a cuboid.
%               [xlo, ylo, zlo, xhi, yhi, zhi]
%           Several ranges can be defined by making an (m x 6) array:
%               [xlo(1), ylo(1), zlo(1), xhi(1), yhi(1), zhi(1);
%                xlo(2), ylo(2), zlo(2), xhi(2), yhi(2), zhi(2); ...]
%
%  'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%
%  'select' Calculates the returned function values, yout, only at the points
%           that were selected for fitting by 'keep' and 'remove'; all other
%           points are set to NaN. This is useful for plotting the output, as
%           only those points that contributed to the fit will be plotted.
%
% Output:
% =======
%   wout    3D dataset object containing the evaluation of the function for the
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

wout = win;
for i = 1:length(win)
    qw = dnd_calculate_qw(get(win));
    [s,e]=dnd_normalise_sigerr(win(i).s,win(i).e,win(i).n);   % normalise data by no. points
    s = reshape(s,numel(s),1); 
    e = sqrt(reshape(e,numel(e),1));% recall that datasets hold variance, no error bars

    if i>1, fitdata(numel(win))=fitdata(1); end    % preallocate
    [sout, fitdata(i)] = fit(qw, s, e, sqwfunc, pin, varargin{:});
    
    wout(i).s = reshape(sout,size(win(i).s));
    wout(i).e = zeros(size(win(i).e));  
    wout(i).n = double(~isnan(wout(i).s));
end
