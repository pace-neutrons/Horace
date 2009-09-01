function [wout, fitdata] = multifit_sqw(win, varargin)
% Simultaneously fits a model for S(Q,w) to an array of sqw objects, with background
% functions varying independently for each sqw object. 
%
% Simultaneously fit several objects to a given function:
%   >> [wout, fitdata] = multifit_sqw (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = multifit_sqw (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = multifit_sqw (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per object
%   >> [wout, fitdata] = multifit_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit_sqw (..., keyword, value, ...)
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%       'evaluate'  evaluate function at initial parameter values only, with argument check as well
%
%   Example:
%   >> [wout, fitdata] = multifit_sqw (..., 'keep', xkeep, 'list', 0)
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
%              The form required for the functions is identical to that for func above.
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
%  A final useful keyword is:
%
%  'evaluate'   Evaluate the fitting function at the initial parameter values only. Useful for
%           checking the validity of starting parameters
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
[pos,func,plist,bpos,bfunc,bplist] = multifit (win, varargin{:},'parsefunc_');
plist={func,plist};
if ~isempty(bpos)
    for i=1:numel(bfunc)
        bplist{i}={bfunc{i},bplist{i}};
    end
end
pos=pos-1; bpos=bpos-1;     % Recall that first argument in the call to multifit was win
varargin{pos}=@sqw_eval;    % The fit function needs to be sqw_eval
varargin{pos+1}=plist;
if ~isempty(bpos)
    varargin{bpos}=@func_eval;
    varargin{bpos+1}=bplist;
end

% Perform the fit
[wout,fitdata] = multifit (win, varargin{:});
