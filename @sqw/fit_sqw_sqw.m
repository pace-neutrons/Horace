function [wout, fitdata, ok, mess] = fit_sqw_sqw(win, varargin)
% Fit a model for S(Q,w) to an sqw object, with an optional background function that is also a model for S(Q,w).
% If passed an array of sqw objects, then each object is fitted independently.
%
% Differs from multifit_sqw_sqw, which fits all objects in the array simultaneously
% but with independent backgrounds.
%
% Fit several objects in succession to a given function:
%   >> [wout, fitdata] = fit_sqw_sqw (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = fit_sqw_sqw (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = fit_sqw_sqw (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' function added to the function
%   >> [wout, fitdata] = fit_sqw_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit_sqw_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit_sqw_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit, call with additional arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = fit_sqw_sqw (...)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = fit_sqw_sqw (..., keyword, value, ...)
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%       'evaluate'  evaluate function at initial parameter values only, with argument check as well
%       'chisqr'    evaluate chi-squared at the initial parameter values (ignored if 'evaluate' not set)
%       'average'   compute the function at the average h,k,l,e of the pixels in a bin
%
%   Example:
%   >> [wout, fitdata] = fit_sqw_sqw (..., 'keep', xkeep, 'list', 0)
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
%   pin     Initial function parameter values
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
%   bkdfunc     -|  Arguments for the background function, defined as for the foreground
%   bpin         |  function.
%   bpfree       |
%   bpbind      -|
%       
%           Examples of a single binding description:
%               {1,4}         Background parameter (bp) 1 is bound to bp 3, with the fixed
%                                  ratio determined by the initial values
%               
%               {5,11,0}      Bp 5 bound to parameter 11 of the foreground fitting function, func
%               {5,11,1}      Bp 5 bound to parameter 11 of the background function
%
%               {5,11,0,0.013}      Explicit ratio for binding bp 5 to parameter 11 of the foreground fitting function
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
%  A final useful set of keyword is:
%
%  'evaluate'   Evaluate the fitting function at the initial parameter values only. Useful for
%               checking the validity of starting parameters.
%
%  'chisqr'     If 'evaulate' is set, then if this option keyword is present the reduced
%               chi-squared is evaluated. Otherewise, chi-squared is set to zero.
%
%  'average'    if sqw object, then compute the function at the average h,k,l,e of the
%               pixels contributing to each bin, rather than for each pixel. This can
%               save a lot of computation
%
% Output:
% =======
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%           If there was a problem for ith data set i.e. ok(i)==false, then wout(i)==w(i) (or wout{i}
%          =[] if cell array input). 
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, then fitdata=[].
%
%   fitdata Result of fit for each dataset
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors of foreground parameters (=0 for fixed parameters)
%               fitdata.bp     - background parameter values
%               fitdata.bsig   - estimated errors of background (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%               fitdata.bpnames- background parameter names
%           If there was a problem for ith data set i.e. ok(i)==false, then fitdata(i)
%          will be dummy. 
%           If there was a fundamental problem e.g. incorrect input argumnet syntax, then
%          fitdata=[].
%
%   ok      True if all ok, false if problem fitting. 
%           If an array of input datasets was given, then ok is an array with the size of the
%          input data array. 
%           If the error was fundamental e.g. wrong argument syntax, then ok will be a scalar.
%
%   mess    Character string contaoning error message if ~ok; '' if ok
%           If an array of datasets was given, then mess is a cell array of strings with the
%          same size as the input data array. 
%           If the error was fundamental e.g. wrong argument syntax, then
%          mess will be a simple character string.
%
%
% EXAMPLES: 
%
% Fit a spin waves to a collection of sqw objects, allowing only intensity and coupling constant to vary:
%   >> ht=100; SJ; gamma=3;
%   >> [wout, fdata] = fit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], [1,1,0])
%
% Fit aan array of cuts independently, with spin waves on to ov a broad paramagnon response
%   >> ht=100; SJ; gamma=3;
%   >> ht_pm-5; gamma0_pm=4;
%   >> [wout, fdata] = fit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], @paramagnon, [ht_pm,gamma0_pm]...
%                               'keep',[-1.5,0.5])


% Catch case of a single dataset input
% ------------------------------------
if numel(win)==1
    [wout,fitdata,ok,mess]=multifit_sqw_sqw(win,varargin{:});
    if ~ok && nargout<3, error(mess), end
    return
end

% Case of more than one dataset input
% -----------------------------------
% First, strip out the appearance of the keyword 'average'
arglist = struct('average',0);
flags={'average'};
[varargin,opt] = parse_arguments(varargin,arglist,flags,false);

% Parse the input arguments, and repackage for fit sqw
[ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] = multifit_gateway_parsefunc (win(1), varargin{:});
if ~ok
    wout=[]; fitdata=[];
    if nargout<3, error(mess), else return, end
end
ndata=1;     % There is just one argument before the varargin
pos=pos-ndata;
bpos=bpos-ndata;

% Wrap the foreground and background functions
if ~opt.average, wrap_plist={}; else wrap_plist={'ave'}; end
args=multifit_gateway_wrap_functions (varargin,pos,func,plist,bpos,bfunc,bplist,...
                                                    @sqw_eval,wrap_plist,@sqw_eval,wrap_plist);

% Evaluate function for each element of the array of sqw objects
wout=win;
fitdata=repmat(struct,size(wout));  % array of empty structures
ok=false(size(wout));
mess=cell(size(wout));

ok_fit_performed=false;
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    [ok(i),mess{i},wout_tmp,fitdata_tmp] = multifit_gateway_main (win(i), args{:});
    if ok(i)
        wout(i)=wout_tmp;
        if ~ok_fit_performed
            ok_fit_performed=true;
            fitdata=expand_as_empty_structure(fitdata_tmp,size(wout),i);
        else
            fitdata(i)=fitdata_tmp;
        end
    else
        if nargout<3, error([mess{i}, ' (dataset ',num2str(i),')']), end
        disp(['ERROR (dataset ',num2str(i),'): ',mess{i}])
    end
end
