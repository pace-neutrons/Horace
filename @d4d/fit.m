function [wout, fitdata] = fit(win, func, pin, varargin)
% Fitting routine for a 4D dataset. If passed an array of 
% 4D datasets, then each is fitted independently to the same function.
%
% Syntax:
%   >> [wout, fitdata] = fit(win, func, pin)
%   >> [wout, fitdata] = fit(win, func, pin, pfree)
%   >> [wout, fitdata] = fit(win, func, pin, pfree, keyword, value)
%
%   keyword example:
%   >> [wout, fitdata] = fit(..., 'fit', fcp)
%
% Input:
% ======
%   win     4D dataset object or array of 3D dataset objects to be fitted
%
%   func    Handle of the function to fit to the data. Function should be of form
%               y = myfunc(x1,x2,x3,x4,p)
%           where
%               x1...x4 = Arrays with the coordinates (x1,x2,x3,x4) of the points
%                         at which to calculate the y values
%               p       = Vector of parameter values needed 
%             e.g.
%               function y = gauss(x1,x2,x3,x4,p)
%               y = p(1)*exp(-0.5*((x1-p(2))/p(6)).^2 + (x2-p(3))/p(7)).^2 +...
%                                  (x3-p(4))/p(8)).^2 + (x4-p(5))/p(9)).^2);
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
%           quartets of numbers which define the corners of a hypercuboid.
%               [xlo, ylo, zlo, wlo, xhi, yhi, zhi, whi]
%           Several ranges can be defined by making an (m x 6) array:
%               [xlo(1), ylo(1), zlo(1), wlo(1), xhi(1), yhi(1), zhi(1), whi(1);
%                xlo(2), ylo(2), zlo(2), wlo(2), xhi(2), yhi(2), zhi(2), whi(2); ...]
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
%   wout    4D dataset object containing the evaluation of the function for the
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
    p1 = 0.5*(win(i).p1(1:end-1)+win(i).p1(2:end));
    p2 = 0.5*(win(i).p2(1:end-1)+win(i).p2(2:end));
    p3 = 0.5*(win(i).p3(1:end-1)+win(i).p3(2:end));
    p4 = 0.5*(win(i).p4(1:end-1)+win(i).p4(2:end));
    [p1, p2, p3, p4] = ndgrid(p1,p2,p3,p4); % mesh x and y 
    p1 = reshape(p1,numel(p1),1);   % get x into single column
    p2 = reshape(p2,numel(p2),1);   % get y into single column
    p3 = reshape(p3,numel(p3),1);   % get z into single column
    p4 = reshape(p4,numel(p4),1);   % get z into single column
    [s,e]=dnd_normalise_sigerr(win(i).s,win(i).e,win(i).n);   % normalise data by no. points
    s = reshape(s,numel(s),1); 
    e = sqrt(reshape(e,numel(e),1));% recall that datasets hold variance, no error bars

    if i>1, fitdata(numel(win))=fitdata(1); end    % preallocate
    [sout, fitdata(i)] = fit([p1, p2, p3, p4], s, e, func, pin, varargin{:});
    
    wout(i).s = reshape(sout,size(win(i).s));
    wout(i).e = zeros(size(win(i).e));  
    wout(i).n = int16(~isnan(wout(i).s));
end
