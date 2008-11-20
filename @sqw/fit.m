function [wout, fitdata] = fit(win, func_handle, pin, varargin)
% Fits a function to an sqw object. If passed an array of 
% sqw objects, then each is fitted independently to the same function.
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
%           Applies only to input with no pixel information - this option is 
%           ignored if the input is a full sqw object.
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

% NOTE:
%   If 'all' then npix=ones(size(win.data.s)) to ensure that the plotting is performed
%   Thus lose the npix information.


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Set defaults:
arglist = struct('fitcontrolparameters',[0.0001 30 0.0001],...
                 'list',0,'keep',[],'remove',[],'mask',[],'selected',0,'all',0);
flags = {'selected','all'};

% Parse parameters:
[args,options] = parse_arguments(varargin,arglist,flags);

% Check input arguments:
if options.selected && options.all
    error ('Cannot have both ''selected'' and ''all'' options at the same time')
end

% Determine if 'all' is an option, and remove any occurences, so can pass options list to generic fit algorithm
% (*** would be nicer if there was a better way to strip options)
all_index=false(1,length(varargin));
for i=1:length(varargin)
    if ischar(varargin{i}) && ~isempty(strmatch(lower(varargin{i}),'all')) % option 'all' given
        all_index(i)=true;
    end
end
varargin=varargin(~all_index);


% Check if any objects are zero dimensional before evaluating fuction, to save on possible expensive computations
% before a 0D object is found in the array
for i = 1:numel(win)
    if isempty(win(i).data.pax)
        error('func_eval not supported for zero dimensional objects');
    end
end

wout = win;
if ~iscell(pin), pin={pin}; end     % package parameters as a cell for convenience

% Evaluate function for each element of the array of sqw objects
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    ndim=length(win(i).data.pax);
    ok=(win(i).data.npix~=0);

    % Get bin centres
    pcent=cell(1,ndim);
    for n=1:ndim
        pcent{n}=0.5*(win(i).data.p{n}(1:end-1)+win(i).data.p{n}(2:end));
    end
    if ndim>1
        pcent=ndgridcell(pcent);%  make a mesh; cell array input and output
    end
    for n=1:ndim
        pcent{n}=pcent{n}(:);   % convert into column vectors
        pcent{n}=pcent{n}(ok);  % pick out only those bins at which there is data
    end
    
    s=win(i).data.s(ok);        % produces column vector of data to be retained
    e=sqrt(win(i).data.e(ok));  % column vector
    
    % Fit function to the data
    if i==1
        [sout, fitdata] = fit(pcent, s, e, func_handle, pin, varargin{:});
        if numel(win)>1
            fitdata=repmat(fitdata,size(win));  % preallocate
        end
    else
        [sout, fitdata(i)] = fit(pcent, s, e, func_handle, pin, varargin{:});
    end
    
    % Fill output structures
    sqw_type = is_sqw_type(win(i));
    if sqw_type || ~option.all
        removed=isnan(sout);        % data points removed by 'keep', 'remove', and 'mask' options
        if any(removed)
            sout(removed)=0;            % conventional contents of empty bins
            ind=find(ok);               % index of the bins that were sent to the fitting routine
            ind=ind(removed);           % index of bins that were removed by 'keep' etc .
            wout(i).data.npix(ind)=0;   % to ensure that these points are removed
            if sqw_type
                mask=false(size(win(i).data.npix));
                mask(ind)=true;
                wout(i).data.pix=compress_array (win(i).data.pix, win(i).data.npix, mask);
            end
        end
        wout(i).data.s(ok)=sout;    % replace data with calculated values using fitted parameters
        wout(i).data.e = zeros(size(win(i).data.e));
        if sqw_type
            s = replicate_array(wout(i).data.s, wout(i).data.npix)'; % If sqw object, fill every pixel with the value of its corresponding bin
            wout(i).data.pix(8:9,:) = [s;zeros(size(s))];
        end
    elseif all_bins
        wout(i).data.s = func_handle(pcent{:},fitdata.p,pin{2:end});% need to evaluate at fitted parmaeter values at all bins
        wout(i).data.e = zeros(size(win(i).data.e));
        wout(i).data.npix=ones(size(win(i).data.npix));    % in this case, must set npix>0 to be plotted.
    end
end
