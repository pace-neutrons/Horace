function [wout, fitdata] = fit_sqw(win, varargin)
% Fit model for S(Q,w) to sqw object or array of sqw objects. If passed an array of 
% sqw objects, then each is fitted independently to the same function.
%
% Differs from multifit_sqw, which fits all objects in the array simultaneously
% but with independent backgrounds.
%
% Fit several objects in succession to a given function:
%   >> [wout, fitdata] = fit_sqw (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = fit_sqw (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = fit_sqw (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' function added to the function
%   >> [wout, fitdata] = fit_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = fit_sqw (..., keyword, value, ...)
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%
%   Example:
%   >> [wout, fitdata] = fit_sqw (..., 'keep', xkeep, 'list', 0)
%
%
% Input:
% ======
%   win     sqw object or array of sqw objects to be fitted
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
%   pin     Initial function parameter values [pin(1), pin(2)...]
%            - If the function my_function takes just a numeric array of parameters, p, then this
%             contains the initial values [pin(1), pin(2)...]
%            - If further parameters are needed by the function, then wrap as a cell array
%               {[pin(1), pin(2)...], c1, c2, ...}  
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
%
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,0,7.4)         parameter 1 is bound to parameter 3, ratio 7.4 (the extra '0' is required)
%             pbind={{1,3,0,7.4},{4,3,0,0.023},{5,6}}
%
%           To bind to background parameters (see below), use the function index unity:
%             pbind={1,3,1}             Parameter 1 bound to background parameter 3 
%
%             pbind={1,3,1,3.14}        Give explicit binding ratio.
%
%
%   Optional background function:
%   --------------------------------
%
%   bkdfunc     -|  Arguments for the background function, defined as for the 'foreground'
%   bpin         |  parameters.
%   bpfree       |
%   bpbind      -|
%       
%           Examples of a single binding description:
%               {1,4}         Background parameter (bp) 1 is bound to bp 3, with the fixed
%                                  ratio determined by the initial values
%               
%               {5,11,0}      Bp 5 bound to parameter 11 of the global fitting function, func
%               {5,11,1}      Bp 5 bound to parameter 11 of the background function
%
%               {5,11,0,0.013}      Explicit ratio for binding bp 5 to parameter 11 of the global fitting function
%               {1,4,1,14.15}       Explicit ratio for binding bp 1 to bp 4 of background function
%
%           Several binding descriptions:
%               {{1,3},{2,4,0,1.2},{5,11,1}}
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
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%
%   fitdata Result of fit for each dataset
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors of global parameters (=0 for fixed parameters)
%               fitdata.bp     - background parameter values
%               fitdata.bsig   - estimated errors of background (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%               fitdata.bpnames- background parameter names
%
% EXAMPLES: 
%
% Fit a spin waves to a collection of sqw objects, allowing only intensity and coupling constant to vary:
%   >> weight=100; SJ; gamma=3;
%   >> [wfit, fdata] = multifit_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], [1,1,0])
%
% If an array of 1D cuts: allow all parameters to vary, only keep data in restricted range, and allow
% independent linear background for each cut in the units of the x axis:
%   >> weight=100; SJ; gamma=3;
%   >> const=0; slope=0;
%   >> [wfit, fdata] = multifit_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], @linear, [const,slope]...
%                               'keep',[-1.5,0.5])


% Parse the input arguments, and repackage for fit sqw
[pos,func,plist,bpos,bfunc,bplist] = multifit (win(1), varargin{:},'parsefunc_');
plist={func,plist};
if ~isempty(bpos)
    for i=1:numel(bfunc)
        bplist{i}={bfunc{i},bplist{i}};
    end
end
pos=pos-1; bpos=bpos-1;     % Recall that first argument in the call to multifit was win
varargin{pos}=@sqw_eval;   % The fit function needs to be func_eval
varargin{pos+1}=plist;
if ~isempty(bpos)
    varargin{bpos}=@func_eval;
    varargin{bpos+1}=bplist;
end

% Evaluate function for each element of the array of sqw objects
wout=win;

for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    if i==1
        [wout(i),fitdata] = multifit (win(i), varargin{:});
        if numel(win)>1
            fitdata=repmat(fitdata,size(win));  % preallocate
        end
    else
        [wout(i),fitdata(i)] = multifit (win(i), varargin{:});
    end
end
