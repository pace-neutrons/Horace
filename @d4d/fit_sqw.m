function [wout, fitdata] = fit_sqw(win, sqwfunc, pin, varargin)
% Fitting routine for a 4D dataset. If passed an array of 
% 4D datasets, then each is fitted independently to the same function.
%
% Syntax:
%   >> [wout, fitdata] = fit(win, sqwfunc, pin)
%   >> [wout, fitdata] = fit(win, sqwfunc, pin, pfree)
%   >> [wout, fitdata] = fit(win, sqwfunc, pin, pfree, keyword, value)
%
%   keyword example:
%   >> [wout, fitdata] = fit(..., 'fit', fcp)
%
% Input:
% ======
%   win     4D dataset object or array of 3D dataset objects to be fitted
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
%   'keep'  Ranges of data to retain for fitting. A range is specified by two 
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
%   'all'   Requests that the calculated function be returned over
%           the whole of the domain of the input dataset. If not given, then
%           the function will be returned only at those points of the dataset
%           that contain data.
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
    qw = dnd_calculate_qw(get(win));
    [s,e]=dnd_normalise_sigerr(win(i).s,win(i).e,win(i).n);   % normalise data by no. points
    s = reshape(s,numel(s),1); 
    e = sqrt(reshape(e,numel(e),1));% recall that datasets hold variance, no error bars

    if i>1, fitdata(numel(win))=fitdata(1); end    % preallocate
    [sout, fitdata(i)] = fit(qw, s, e, sqwfunc, pin, varargin{:});
    
    wout(i).s = reshape(sout,size(win(i).s));
    wout(i).e = zeros(size(win(i).e));  
    if ~all_option  % no option given
        wout(i).n = int16(~isnan(wout(i).s) & win(i).n~=0);  % return data only at the points where there is data
    else
        wout(i).n = ones(size(win(i).n));
    end
end
