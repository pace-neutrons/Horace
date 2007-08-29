function [wout, fitdata] = fit(win, func, pin, varargin)
% Fitting routine for a 2D dataset. If passed an array of 
% 2D datasets, then each is fitted independently to the same function.
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
%   win     2D dataset object or array of 2D dataset objects to be fitted
%
%   func    Handle of the function to fit to the data. Function should be of form
%               y = myfunc(x1,x2,p)
%           where
%               x1,x2 = Arrays with the coordinates (x1,x2) of the points
%                      at which to calculate the y values
%               p     = Vector of parameter values needed 
%             e.g.
%               function y = gauss(x1,x2,p)
%               y = p(1)*exp(-0.5*((x1-p(2))/p(4)).^2  (x2-p(3))/p(5)).^2);
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


% Determine if 'all' is an option, and remove any occurences
all_option=false;
all_index=false(1,length(varargin));
for i=1:length(varargin)
    if ischar(varargin{i}) && ~isempty(strmatch(lower(varargin{i}),'all')) % option 'all' given
        all_option=true;
        all_index(i)=true;
    end
end
varargin=varargin(~all_index);

% Perform the fit
wout = win;
for i = 1:length(win)    
    
    if (length(win(i).p1)~=size(win(i).s,1)) % check for point / histrogram and turn into point. 
       p1 = 0.5*(win(i).p1(1:end-1)+win(i).p1(2:end));
    else
        p1 = win(i).p1;
    end
    if (length(win(i).p2)~=size(win(i).s,2))
        p2 = 0.5*(win(i).p2(1:end-1)+win(i).p2(2:end));
    else
       p2 = win(i).p2;
    end

    [p1, p2] = ndgrid(p1,p2);       % mesh x and y 
    p1 = reshape(p1,numel(p1),1);   % get x into single column
    p2 = reshape(p2,numel(p2),1);   % get y into single column

    s = reshape(win.s,numel(win.s),1); 
    e = sqrt(reshape(win.e,numel(win.e),1));% recall that datasets hold variance, no error bars

    if i>1, fitdata(numel(win))=fitdata(1); end    % preallocate
    [sout, fitdata(i)] = fit([p1, p2], s, e, func, pin, varargin{:});
    
    wout(i).s = reshape(sout,size(win(i).s));
    wout(i).e = zeros(size(win(i).e));  

    if options.all  % if all data, then turn nans into 0's 
        wout(i).s(isnan(wout(i).s)) = 0;
    end
    
end
