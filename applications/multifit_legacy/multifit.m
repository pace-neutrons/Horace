function varargout = multifit(varargin)
% Find best fit of a parametrised function to data with an arbitrary number of dimensions.
%
% The data can be x,y,e arrays or objects of a class.
%
% Simultaneously fit several objects to a given function:
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
%       'evaluate'  evaluate at the initial parameter values (convenient to test starting values)
%       'chisqr'    evaluate chi-squared at the initial parameter values (ignored if 'evaluate' not set)
%
%   Example:
%   >> [wout, fitdata] = multifit (..., 'keep', xkeep, 'list', 0)
%
%
% Input:
% ======
%   Data to be fitted: 
%       x       Coordinates of the data points:
%               - An array of any size whose outer dimension gives the
%                coordinate dimension i.e. x(:,:,...:,1) is the array of
%                x values along axis 1, x(:,:,...:,2 along axis 2) ...
%                to x(:,:,...:,n) along the nth axis.
%                 The exception is if size(x) matches size(y), then the outer dimension
%                is taken as unity and the data is considered to be one dimensional
%                   e.g. x=[1.1, 2.3, 4.3    &  y=[110, 121, 131
%                           1.7, 5.4, 7.0]         141, 343,  89]
%           or  - A cell array of length n, where x{i} gives the coordinates in the
%                ith dimension for all the data points. The arrays can have any
%                size, but they must all have the same size.
%
%       y       Array of the of data values at the points defined by x. Must
%               have the same same size as x(:,:,...:,i) if x is an array, or
%               of x{i} if x is a cell array.
%
%       e       Array of the corresponding error bars. Must have same size as y.
%   
%   Alternatively:
%       w   - Structure with fields w.x, w.y, w.e  with form described above  (this is a single dataset)
%           - Array of structures w(i).x, w(i).y, w(i).e  with form above (this defines several datasets)
%           - Cell array of structures, each element a single dataset
%           - Array of objects to be fitted.
%           - Cell array of objects to be fitted.
%           If a cell array, not all the objects need to be of the same class, so long as the
%          the function to be fitted is defined as a method for each of the class types.
%
%           Notes on required methods if adding objects other than x-y-e triples:
%           (1) The global function and background function (if given) must be methods, with
%               input argument form as described below in detail; the general format is
%                   >> wcalc = my_function (w,p,c1,c2,...)
%
%           (2) A method that returns the intensity and variance arrays from the objects, along with
%               a mask array that indicates which elements are to be ignored:
%                   >> [y,var,msk] = sigvar_get(w)
%
%           (3) A method that masks data points from further calculation:
%                   >> wout = mask (win, mask_array)
%               (elements of mask_array: 1 to keep a point, 0 to remove from fitting)
%
%           ($) *EITHER*
%               A method that returns and array of the x values (one dimensional data) or
%               a cell array of arrays of the the x1, x2, x3... values for every point
%               in the object
%                   >> x = sigvar_getx (w)
%               (The size and shape of each of the x arrays must match those of the
%                y and e arrays returned by sigvar_get, in point (2).)
%
%               *OR*
%               Create a mask array given ranges of x-coordinates to keep &/or remove &/or &/or mask array
%               Must output a logical flag ok, with message string if ~ok rather than terminate. (Can
%               have it terminate if ok and mess are not given as return arguments; it is the advanced
%               syntax that is required within multifit)
%                   >> [sel, ok, mess] = mask_points (win, 'keep', xkeep, 'xremove', xremove, 'mask', mask)
%               (Normally this method would not be supplied sigvat_getx is easy to
%                code, but special knowledge of the class could make mask_points more efficient.)
%
%           (5) If a background function is provided, addition of objects must be defined as
%                   >> wsum = w1 + w2
%               (requires overloading of the addition operator with a method named plus.m)
%
%   func    Function handle to function to be fitted to each of the objects.
%           If x,y,e or structure(s) with fields w.x,w.y,w.e, must have form:
%               ycalc = my_function (x,p)
%
%             or, more generally:
%               ycalc = my_function (x,p,c1,c2,...)
%
%           If objects, then:
%               wcalc = my_function (w,p)
%
%             or, more generally:
%               wcalc = my_function (w,p,c1,c2,...)
%
%               - p         a vector of numeric parameters that can be fitted
%               - c1,c2,... any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%
%           The functions can be nested. The examples below illustrate why this might
%           be necessary. The convention that is adopted is
%               func1 (w, @func2, {p}, c1, c2, ...) => func1 (func2(w,p{:}), c1, c2,...)
%           
%           EXAMPLE: Fit a model for S(Q,w) to an sqw object:
%               Will have a function to compute S(Q,w) with the standard form:
%                   weight = my_sqwfunc (qh, qk, ql, en, p, c1, c2,..)
%
%               and there is a method of sqw to evaluate this function:
%                   wcalc = sqw_eval (w, @my_sqwfunc, {p, c1, c2, ...})
%
%               Consequently, because we have chosen the convention for nesting functions: 
%                   func1 (w, @func2, {p}, c1, c2, ...) => func1 (func2(w,p{:}), c1, c2,...)
%
%               then the model for S(q,w) can be fitted by the call:
%                   multifit(w, @sqw_eval, {@my_sqwfunc, {p, c1, c2,...}})
%
%           EXAMPLE: Resolution convolution of S(Q,w):
%               Will have a method of sqw class that takes a model for S(Q,w) and 
%              convolutes with the resolution function:
%                   wres = resconv (w, @my_sqwfunc, {p,c1,c2,...}, res_p1, res_p2,...)
%
%               In this case, the function call will be:
%                   multifit (w, @resconv, {@my_sqwfunc, {p, c1, c2,...}, res_p1, res_p2,...})
%
%
%   pin     Initial function parameter values
%            - If the function my_function takes just a numeric array of parameters, p, then this
%             contains the initial values [pin(1), pin(2)...]
%            - If further parameters are needed by the function, then wrap as a cell array
%               {[pin(1), pin(2)...], c1, c2, ...}  
%
%   pfree   [Optional] Indicates which are the free parameters in the fit.
%           e.g. if length(p)=5, then pfree=[1,0,1,0,0] indicates first and third are free
%           Default: all are free. Similarly, pfree=[] is interpreted as all being free.
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
%          NOTE***
%             The insistence on bpin being a cell array resolves an ambiguity. Otherwise, for exanple,
%            if length(w)==4, and length(bkdfunc)=1, then if iscell(bpin) and length(bpin)==4, then
%            this could mean that the cell array is to be passed to bkdfunc as the list of
%            parameters, and is the same for each element of w. Equally, it could mean that we have four
%            different initial parameter sets for the same function, one per element of w.
%             With the syntax demanded here, only the latter interpretation is possible.
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
%          NOTE***
%             The insistence on bpin being a cell array resolves the same type of ambiguity as was
%            solved for bpin
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
%           A range is specified by an array of numbers which define a hypercube.
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
%           of the data points are to be retained for fitting (1=keep, 0=remove).
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
%           Has the same form as the input data. The only exception is if x,y,e were given as
%          three separate arrays, only ycalc is returned.
%           If there was a problem i.e. ok==false, wout=[]
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
%           If there was a problem i.e. ok==false, fitdata=[]
%
%   ok      True if all ok, false if problem fitting. 
%
%   mess    Character string contaoning error message if ~ok; '' if ok
%
%
%   Examples:
%       Fit five one-dimensional sqw objects to a model for S(Q,w) broadened by the
%       instrument resolution function. The resolution model depends on two parameters
%       r1, r2, and the S(Q,w) model uses two large arrays c1, c2 in addition to the 
%       fitting parameters p. The 4th and 5th parameters of p are constraint to vary with
%       a fixed ratio; parameters 2 and 3 are fixed. Each sqw object has its own independent
%       quadratic background, but all have the same initial parameter values.
%       Two of them are constrained to a linear background.
%
%           >> [wfit,fitdata] = multifit (w,...
%                          @resconv, {@my_sqwfunc,{p,c1,c2},r1,r2}, [1,0,0,1,1], {4,5},...
%                          @func_eval, {{@quad,[1.1,0.1,0.02]}}, {[],[1,1,0],[],[],[1,1,0]} )

% Parsing input parameters
% ========================
% A feature not documented above is one to locate the presence of the global fitting function
% and any background functions, withut actually fitting. This has a use, for example, when
% repackaging the input for a custom call to multifit.
%
%   >> [pos,func,plist,bpos,bfunc,bplist,ok,mess] = multifit (...,'parsefunc_')
%
% This is only included for backwards compatibility. Please use the official gateway
% function multifit_gateway
%
%   >> [wout,fitdata,ok,mess] = multifit_gateway (...)
%   >> [pos,func,plist,bpos,bfunc,bplist,ok,mess] = multifit_gateway (...,'parsefunc_')
%
% See code for multifit_gateway for more details

[ok,mess,output]=multifit_main(varargin{:});
nout=numel(output);
if ok || nout<nargout   % if not ok, then ok is a return argument
    n=min(nout,nargout);
    varargout(1:n)=output(1:n);
    if nargout>=nout+1, varargout{nout+1}=ok; end
    if nargout>=nout+2, varargout{nout+2}=mess; end
else
    error(mess)
end
