function [wout, fitdata, ok, mess] = multifit(win, varargin)
% Simultaneously fits a function to one or more IX_dataset_1d objects
% Optionally allow with background functions varying independently for each dataset. 
%
% Simultaneously fit one or more datasets to a given function:
%   >> [wout, fitdata] = multifit (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = multifit (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = multifit (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per object
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin, bpfree, bpbind)
%
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit, call with additional arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = multifit (...)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit (..., keyword, value, ...)
%
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%       'evaluate'  evaluate function at initial parameter values only, with argument check as well
%       'chisqr'    evaluate chi-squared at the initial parameter values (ignored if 'evaluate' not set)
%
%   Example:
%   >> [wout, fitdata] = multifit (..., 'keep', xkeep, 'list', 0)
%
%
% Input:
% ======
%   w       IX_dataset_1d or array of IX_dataset_1d objects to be fitted
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
%           To bind to background parameters (see below), give the index of the background function
%           handle in the cell array bkdfunc defined below.
%             pbind={1,3,[7,2]}         parameter 1 bound to background parameter 3 of background
%                                       function handle bkdfunc{7,2}.
%
%             pbind={1,3,[7,2],3.14}    Give explicit binding ratio.
%
%
%   Optional background function(s):
%   --------------------------------
%   It is sometimes convenient to fit a global function, func, to the collection of objects w,
%   but have a function that might be used to provide an object-specific background. For example,
%   we may want to fit S(Q,w) to several one-dimensional cuts, but have an independent linear 
%   background for each cut. These are defined similarly to the above
%
%  bkdfunc  Cell array of background function handles
%            - If contains a single handle, then the same function applies to every object 
%              in the collection of objects, w, that is to be fitted.
%             (Internally, is expanded into a cell array of the same size as w. If wish to bind
%              background parameters to a particular background handle, then refer to the 
%              corresponding index of that expanded array).
%            - Otherwise, the size of the cell array must match the size of w, and there
%              will be a one-to-one correspondence of the background function handles to the elements of w.
%           The form required for the functions is identical to that for func above.
%   
%   bpin    Cell array of initial parameter values for the background function(s), following the 
%           same definitions and conventions as pin
%            - If a single element in the cell array, then will be used for every background function;
%            - Otherwise, the size of the cell array must match the size of w, and there will be a
%              one-to-one correspondence of the elements to the background initial parameters
%
%   bpfree  Array, or cell array of arrays indicating which parameters are free to vary.
%            - If single array, or cell array with a single array, then applies to every background function
%            - Otherwise, the size of the cell array must match the size of w, and there will be a
%              one-to-one correspondence of the elements to indicate the free background parameters
%
%   bpbind  Cell array of binding cell arrays of the form defined for pbind. Indicates how background
%           parameters are bound. Take care here: as the object that defined the binding is itself
%           a cell array of cell arrays, it is easy to get confused as to whether the binding description
%           applies to all background functions, or if it is a set of distinct binding descriptions, one
%           for each background function. The size of the outermost cell array dictates which:
%            - If a single element in the cell array, then will be used for every background function;
%            - Otherwise, the size of the cell array must match the size of w, and there will be a
%              one-to-one correspondence of the elements to the background functions.
%       
%           Examples of a single binding description:
%               {1,4}         Background parameter (bp) 1 is bound to bp 3, with the fixed
%                                  ratio determined by the initial values
%               {2,3,[7,2]}   Bp 2 bound to bp 3 of background function handle bkdfunc{7,2}
%               {5,11,0}      Bp 5 bound to parameter 11 of the global fitting function, func
%               {{1,4}, {2,3,[7,2]}, {5,11,0}}        Several bindings defined together
%
%               {5,11,0,0.013}      Explicit ratio for binding bp 5 to parameter 11 of the global fitting function
%               {1,4,[7,2],14.15}   Explicit ratio for binding bp 1 to bp 4 of background function [7,2]
%
%           In a call to multifit: as an example of the need to take care:
%               bpbind = {{1,4}, {2,3,[7,2]}, {5,11,0}}     binding description for three separate backgrounds
%
%               bpbind = { {{1,4}, {2,3,[7,2]}, {5,11,0}} } Binding description for all background functions
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
%   'keep'  Array or cell array of arrays giving ranges of x to retain for fitting.
%            - single array: applies to all elements of w
%            - a cell array of arrays must have length the same as w, and describes the
%             keep ranges for those elements one-by-one.
%
%           A range is specified by an arrayv of numbers which define a hypercube.
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
%   'mask'  Array, or cell array of arrays, of ones and zeros, with the same number
%           of elements as the data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting.
%
%  'select' Calculates the returned function values, wout, only at the points
%           that were selected for fitting by 'keep', 'remove', 'mask' and were
%           not eliminated for having zero error bar etc; this is useful for plotting the output, as
%           only those points that contributed to the fit will be plotted.
%
%  A final useful pair of keyword is:
%
%  'evaluate'   Evaluate the fitting function at the initial parameter values only. Useful for
%               checking the validity of starting parameters.
%
%  'chisqr'     If 'evaulate' is set, then if this option keyword is present the reduced
%               chi-squared is evaluated. Otherewise, chi-squared is set to zero.
%
%
% Output:
% =======
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%           If there was a problem i.e. ok==false, wout=[]
%
%   fitdata Result of fit for each dataset:
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors of global parameters (=0 for fixed parameters)
%               fitdata.bp     - background parameter values
%               fitdata.bsig   - estimated errors of background (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%               fitdata.bpnames- background parameter names
%           If there was a problem i.e. ok==false, fitdata=[]
%
%   ok      True if all ok, false if problem fitting. 
%
%   mess    Character string contaoning error message if ~ok; '' if ok
%
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


% *** This function is identical for IX_dataset_1d, _2d, _3d, ...

% Parse the input arguments, and repackage for fit func
[pos,func,plist,bpos,bfunc,bplist,ok,mess] = multifit_gateway (win, varargin{:},'parsefunc_');
if ~ok
    wout=[]; fitdata=[];
    if nargout<3, error(mess), else return, end
end

% Wrap the foreground and background functions
noff=1;     % There is just one argument before the varargin
args=multifit_gateway_wrap_functions (noff,varargin,pos,func,plist,bpos,bfunc,bplist,...
                                                    @func_eval,{},@func_eval,{});

% Perform the fit
[wout,fitdata,ok,mess] = multifit_gateway (win, args{:});
if ~ok && nargout<3
    error(mess)
end
