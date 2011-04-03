function [zout, fitdata] = fit(x, zarr, errarr, func, pin, varargin)
% Find best fit of a parametrised function to data. Works for arbitrary 
% number of dimensions. Various keywords control output.
%
%   >> [yout, fitdata] = fit(x, y, e, func, pin)
%   >> [yout, fitdata] = fit(x, y, e, func, pin, pfree)
%   >> [yout, fitdata] = fit(x, y, e, func, pin, pfree, keyword, value, ...)
%
%   keyword example:
%   >> [yout, fitdata] = fit(..., 'keep', xkeep, 'list', 0)
%
% Each data value in the vector of points y is located in an n-dimensional
% space by coordinates x(1),x(2),x(3)...x(n); the fit function is a function
% of n coordinates. 
%
% Input:
% ======
%   x       Coordinates of the data points:
%               - An array of any size whose outer dimension gives the
%                coordinate dimension i.e. x(:,:,...:,1) is the array of
%                x values along axis 1, x(:,:,...:,2 along axis 2) ...
%                to x(:,:,...:,n) along the nth axis.
%      OR       - A cell array of length n, where x{i} gives the coordinates in the
%                ith dimension for all the data points. The arrays can have any
%                size, but they must all have the same size.
%
%   y       Array of the of data values at the points defined by x. Must
%           have the same same size as x(:,:,...:,i) if x is an array, or
%           of x{i} if x is a cell array.
%
%   e       Array of the corresponding error bars. Must have same size as y.
%
%   func    Function handle to function to be fitted e.g. @gauss
%           Must have form:
%               y = my_function (x1,x2,... ,xn,p,c1,c2,...)
%
%            or, more generally:
%               y = my_function (x1,x2,... ,xn,p)
%
%               - p         a vector of numeric parameters that can be fitted
%               - c1,c2,... any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%           
%           e.g. Two dimensional Gaussian:
%               function y = gauss2d(x1,x2,p)
%               y = p(1).*exp(-0.5*(((x1 - p(2))/p(4)).^2+((x2 - p(3))/p(5)).^2);
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
%   'keep'  Ranges of x to retain for fitting. A range is specified by an array
%           of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%  'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. xremove takes precendence over xkeep.
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
% Output:
% =======
%   yout    Value of function for the fitted parameter values
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

% Check the pin is a cell array with the correct form:
if ~iscell(pin)
    if ~isvector(pin) || ~isnumeric(pin)
        error('Input must be a numeric vector or cell array of parameters');
    end
    pin={pin};      % wrap as a cell array for internal use
elseif iscell(pin)
    if ~isvector(pin{1}) || ~isnumeric(pin{1})
        error('1st element of input cell array must be a numeric vector');
    end
end

% Set defaults:
arglist = struct('fitcontrolparameters',[0.0001 30 0.0001],...
                 'list',0,'keep',[],'remove',[],'mask',[],'selected',0);
flags = {'selected'};

% Parse parameters:
[args,options] = parse_arguments(varargin,arglist,flags);

% Check input data:
if isnumeric(x)
    x = num2cell(x,1:(ndims(x)-1));  % separate the dimensions into cells
elseif iscell(x)
    sz=size(x{1});
    for i=2:length(x)
        if ~isequal(sz,size(x{i}))
            error('Array sizes of input coordinate arrays must all be equal')
        end
    end
end
sz=size(x{1});
if ~isequal(sz,size(zarr))||~isequal(sz,size(errarr))
    error('Signal and error array sizes must match coordinate array(s) size')
end

% Check input arguments
pfree=ones(size(pin{1}));
if length(args)>=1
    pfree=args{1};
    if ~(isa_size(pfree,size(pin{1}),'numeric') && all(pfree==1|pfree==0))
        error ('Check argument pfree is all 0 or 1 and length of pin (1st cell array element)')
    end
end

% Check options values:
ndim = length(x);
if ~isempty(options.keep)
    if size(options.keep,2)/2~=ndim || length(size(options.keep))~=2
        error(['''keep'' must provide a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'])
    end
end
if ~isempty(options.remove)
    if size(options.remove,2)/2~=ndim || length(size(options.remove))~=2
        error(['''remove'' must provide a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'])
    end
end
if ~isempty(options.mask)
    if numel(options.mask)~=numel(zarr)
        error('''mask'' must provide a numeric or logical array with same number of elements as the data')
    end
end

% Determine which points to fit
sel = retain_for_fit(x, zarr, errarr, options.keep, options.remove, options.mask);

x_fit = x;
for i = 1:length(x)
    x_fit{i} = x{i}(sel);
end

z = zarr(sel);
e = errarr(sel);

% Fit data if still data left 
if ~isempty(z)
    [p,sig,corr,chisq,zfit] = fit_lsqr(x_fit,z,e,pin,pfree,func,...
                               options.list,options.fitcontrolparameters);
    
    % Evaluate function at all points in the input data, or only at points used in fit
    if options.selected
        zout=NaN(size(zarr));
        zout(sel)=zfit;
    else
        zout = func(x{:},p{:});
    end
else
    zout=NaN(size(zarr));
    p{1} = NaN(size(pin{1}));
    sig = NaN(size(pin{1}));
    corr = NaN(length(find(pfree)));
    chisq = NaN;
end

% Get names of the parameters
try % assume form of mfit function, but catch in case not
    [dummy1,dummy2,pnames] = func(x{:}, p{1}, 1);
catch
    pnames=cell(1,length(pin{1}));
    for ip=1:length(pin{1})
        pnames{ip}=['p',num2str(ip)];
    end
end

fitdata.p=p{1};
fitdata.sig=sig;
fitdata.corr=corr;
fitdata.chisq=chisq;
fitdata.pnames=pnames;
