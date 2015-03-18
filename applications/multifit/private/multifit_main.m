function [ok,mess,parsing,output] = multifit_main(varargin)
% Fit functions to an array of data sets. In outline:
%
% Simultaneously fit several data sets to a given function (w is an array of several datasets):
%   >> [ok, mess, output] = multifit (w, func, pin)                 % all parameters free
%   >> [ok, mess, output] = multifit (w, func, pin, pfree)          % selected parameters free to fit
%   >> [ok, mess, output] = multifit (w, func, pin, pfree, pbind)   % binding of selected parameters in fixed ratios
%
% Fit x,y,e data:
%   >> [ok, mess, output] = multifit (x, y, e, func, ...)
%
% With optional 'background' functions added to the foreground function, one per data set:
%   >> [ok, mess, output] = multifit (..., bkdfunc, bpin)
%   >> [ok, mess, output] = multifit (..., bkdfunc, bpin, bpfree)
%   >> [ok, mess, output] = multifit (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [ok, mess, output] = multifit (..., keyword, value, ...)
%
%   
% Input:
% ------
%   x,y,e   Arrays containing x corrdinates, values y and error bars e
% OR    w   Structure array, object array or cell array of data sets
%
%   func    Function to be fitted to 
%   pin     Initial parameter values
%   pfree   Logical array of which parameters are free to be varied
%
% Output:
% -------
%   ok      True if no problems, false otherwise
%   mess    If ok, then empty; if ~ok, then contains informative error message
%   parsing True if parsing, false if not
%   output  Cell array with output:
%           - if input arguments have requested fitting or simulation of function
%               output = {wout, fitdata}    % see below for contents
%           - if input arguments have requested parsing of functions, then
%               output = {pos,func,plist,bpos,bfunc,bplist}
%
% This is a private function that is called by the multifit gateway functions multifit and multifit_gateway
%
% Ensure that the documentation below is consistent with that in multifit.m
%
% -------------------------------------------------------------------------------------------------
% Find best fit of a parametrised function to data. Works for an arbitrary 
% number of dimensions. Various keywords control output.
%
% The data can be x,y,e arrays, or objects of a class.
%
% Simultaneously fit several data sets to a given function (w is an array of several datasets):
%   >> [ok, mess, output] = multifit (w, func, pin)                 % all parameters free
%   >> [ok, mess, output] = multifit (w, func, pin, pfree)          % selected parameters free to fit
%   >> [ok, mess, output] = multifit (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' functions added to the global function, one per data set:
%   >> [ok, mess, output] = multifit (..., bkdfunc, bpin)
%   >> [ok, mess, output] = multifit (..., bkdfunc, bpin, bpfree)
%   >> [ok, mess, output] = multifit (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords control which ranges of the data to keep or remove from objects, control fitting algorithm etc.
%   >> [ok, mess, output] = multifit (..., keyword, value, ...)
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
%       'foreground'
%       'background'
%
%     Control if foreground and background functions apply to each dataset independently or are global
%       'global_foreground' Foreground function applies to all datasets [default]
%       'local_foreground'  Foreground function(s) apply to each dataset independently
%
%       'local_background'  Background function(s) apply to each dataset independently [default]
%       'global_background' Background function applies to all datasets
%
%     Apply a pre-processing function to the data before least squares fitting
%       'init_func'         Function handle
%
%   For internal use only:
%     'parsefunc_'  Return function parsing information. For use by developers only.
%
%   Example:
%   >> [ok, mess, output] = multifit (..., 'keep', xkeep, 'list', 0)
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
%
%           or  - A cell array of length n, where x{i} gives the coordinates in the
%                ith dimension for all the data points. The arrays must all have
%                the same size, but there are no restrictions on what that size is.
%
%       y       Array of the data values at the points defined by x. Must
%               have the same same size as x(:,:,...:,i) if x is an array, or
%               of x{i} if x is a cell array.
%
%       e       Array of the corresponding error bars. Must have same size as y.
%   
%   Alternatively:
%       w   - Structure with fields w.x, w.y, w.e  with one of the forms described above
%            (this is a single dataset)
%
%           - Array of structures w(i).x, w(i).y, w(i).e  each with one of the forms
%            described above (this defines several datasets)
%
%           - Cell array of structures, each structure a single dataset
%            (i.e. is a scalar structure)
%
%           - Array of objects
%
%           - Cell array of objects, each object being scalar
%
%           - Cell array of structures or objects, each one corresponding to a
%            single data set
%
%           Data input as a cell array of objects very flexible: not all the objects need to
%          be of the same class, so long as the function being fitted is a method for
%          each of the class types, or is a function that operates correctly on the object.
%
%           Notes on required methods if fitting objects (as opposed to x-y-e triples):
%           (1) The global function and background function (if given) must be methods
%               of the input objects that return objects of the same type, or plain
%               functions that return an object of the same type as the object being fitted.
%               The input argument syntax are described below in detail; the general format is
%                   >> wcalc = my_function (w,p,c1,c2,...)
%
%           (2) A method called sigvar_get that returns the intensity and variance
%               arrays from the objects, along with a mask array that indicates which
%               elements are to be ignored (msk(i)==true to keep, ==false to ignore):
%                   >> [y,var,msk] = sigvar_get(w)
%
%           (3) A method that masks data points from further calculation:
%                   >> wout = mask (win, mask_array)
%               (elements of mask_array: 1 to keep a point, 0 to remove from fitting)
%
%           ($) *EITHER*
%               A method that returns an array of the x values (one dimensional data) or
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
%               (Normally this method would not be supplied because sigvar_getx is easy to
%                code, but special knowledge of the class could make mask_points more efficient.)
%
%           (5) If a background function is provided, addition of objects must be defined as
%                   >> wsum = w1 + w2
%               (requires overloading of the addition operator with a method named plus.m)
%
%   func    Function handle to function to be fitted to each of the objects.
%           If x,y,e or structure(s) with fields w.x,w.y,w.e, it must have the form:
%               ycalc = my_function (x,p)
%
%             or, more generally:
%               ycalc = my_function (x,p,c1,c2,...)
%
%           If objects, then the method or function must have the form:
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
%   pin     Initial function parameter values [pin(1), pin(2)...] of the numeric values that
%           can be fitted. That is, the array p in the documentation for func above.
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
%              The form required for the functions is identical to that for func above.
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
%  For use by developers, there is one more keyword:
%
%  'parsefunc_' If present, locate the presence of the global fitting function and any background
%               functions, withut actually fitting. This has a use, for example, when
%               repackaging the input for a custom call to multifit.
%
%
% Output:
% =======
%   ok      True if no problems; false otherwise
%
%   mess    Error message if ~ok; empty string if ok
% 
%   parsing Logical: =true if just checking parsing; false if fitting or evaluating
%
%   output  Cell array of output; one of the two instances below if ok; empty cell array (1x0) if not ok.
%           EITHER
%               Contains two elements giving results of a fit or simulation
%                 {wout, fitdata}
%           OR
%               Contains details of parsing of input data and functions if 'parsefunc_' keyword was provided
%                 {pos,func,plist,bpos,bfunc,bplist}
%
% Case of {wout, fitdata}:
% ------------------------
%   >> [wout,fitdata,ok,mess] = multifit_gateway (...)
%
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%           Has the same form as the input data. The only exception is if x,y,e were given as
%          three separate arrays, only ycalc is returned.
%           If there was a problem i.e. ok==false, wout=[]
%
%   fitdata Result of fit for each dataset
%               ***
%
%   ok      True if all ok, false if problem fitting. 
%
%   mess    Character string containing error message if ~ok; '' if ok
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
%           >> [ok,mess,output] = multifit (w,...
%                          @resconv, {@my_sqwfunc,{p,c1,c2},r1,r2}, [1,0,0,1,1], {4,5},...
%                          @func_eval, {{@quad,[1.1,0.1,0.02]}}, {[],[1,1,0],[],[],[1,1,0]} )


% ----------------------------------------------------------------------------------------------------------------
% Clean up any persistent or global storage in case multifit was left in a strange state due to error or cntl-c
% ----------------------------------------------------------------------------------------------------------------
multifit_cleanup    % initialise multifit
if matlab_version_num>=7.06     % R2008a or more recent: robust cleanup even if cntl-c
    cleanupObj=onCleanup(@multifit_cleanup);
end


% ----------------------------------------------------------------------------------------------------------------
% Parse arguments and keywords
% ----------------------------------------------------------------------------------------------------------------
% Set defaults:
arglist = struct('fitcontrolparameters',[0.0001 30 0.0001],'list',0,...
                 'keep',[],'remove',[],'mask',[],'selected',0,...
                 'evaluate',0,'foreground',0,'background',0,'chisqr',0,...
                 'local_foreground',0,'global_foreground',1,'local_background',1,'global_background',0,...
                 'init_func',[],'parsefunc_',0);
flags = {'selected','evaluate','foreground','background','chisqr',...
         'local_foreground','global_foreground','local_background','global_background',...
         'parsefunc_'};

% Parse parameters:
[args,options,present] = parse_arguments(varargin,arglist,flags);

% Determine if just parsing the function handles and parameters
if options.parsefunc_
    parsing=true;
    nop=11;
else
    parsing=false;
    nop=2;
end

% Check there are some input arguments
if numel(args)<3    % must have at least w, func, pin
    [ok,mess,output]=multifit_error(nop,'Check number of input arguments'); return;
end

% Check if local or global foreground function
% (If only one if present, over-ride default)
if present.local_foreground && ~present.global_foreground
    local_foreground=options.local_foreground;
elseif ~present.local_foreground && present.global_foreground
    local_foreground=~options.global_foreground;
else
    if options.local_foreground~=options.global_foreground
        local_foreground=options.local_foreground;
    else
        [ok,mess,output]=multifit_error(nop,'Inconsistent options for global and local foreground options'); return;
    end
end

% Check if local or global background function
% (If only one if present, over-ride default)
if present.local_background && ~present.global_background
    local_background=options.local_background;
elseif ~present.local_background && present.global_background
    local_background=~options.global_background;
else
    if options.local_background~=options.global_background
        local_background=options.local_background;
    else
        [ok,mess,output]=multifit_error(nop,'Inconsistent options for global and local foreground options'); return;
    end
end

% Check options for 'evaluate'
fitting=~options.evaluate;
if ~fitting
    eval_chisqr=options.chisqr;
    % Allow one of 'foreground' or 'background' (or their complements) but not both
    % e.g. 'noforeground' is the same as 'background'
    eval_foreground=true;
    eval_background=true;
    if present.foreground && ~present.background
        if options.foreground
            eval_background=false;
        else
            eval_foreground=false;
        end
    elseif ~present.foreground && present.background
        if options.background
            eval_foreground=false;
        else
            eval_background=false;
        end
    elseif present.foreground && present.background
        [ok,mess,output]=multifit_error(nop,'Cannot have both ''foreground'' and ''background'' keywords present'); return
    end
else
    if present.chisqr, [ok,mess,output]=multifit_error(nop,'The option ''chisqr'' is only valid with ''evaluate'' keyword present'); return; end
    if present.foreground, [ok,mess,output]=multifit_error(nop,'The option ''foreground'' is only valid with ''evaluate'' keyword present'); return; end
    if present.background, [ok,mess,output]=multifit_error(nop,'The option ''background'' is only valid with ''evaluate'' keyword present'); return; end
    eval_chisqr=false;
    eval_foreground=true;
    eval_background=true;
end

% Check preprocessor option is a function handle, if present
if ~isempty(options.init_func)
    if isa(options.init_func,'function_handle')
        init_func=options.init_func;
    else
        [ok,mess,output]=multifit_error(nop,'The option ''init_func'' must be a function handle'); return
    end
else
    init_func=[];
end

% ----------------------------------------------------------------------------------------------------------------
% Find position of foreground fitting function(s)
% ----------------------------------------------------------------------------------------------------------------
% The first occurence of a function handle or cell array of function handles will be the foreground function(s)
iarg_fore_func=[];
for i=1:numel(args)
    [ok,mess,func]=function_handles_valid(args{i});
    if ok
        iarg_fore_func=i;
        break
    end
end
if isempty(iarg_fore_func)
    [ok,mess,output]=multifit_error(nop,'Must provide handle(s) to foreground fitting function(s) with valid format'); return;
end


% ----------------------------------------------------------------------------------------------------------------
% Check nature and validity of data type(s) to be fitted
% ----------------------------------------------------------------------------------------------------------------
[ok,mess,w,single_data_arg,cell_data,xye,xye_xarray] = repackage_input_datasets(args{1:iarg_fore_func-1});
if ~ok
    [ok,mess,output]=multifit_error(nop,mess); return;
end


% ----------------------------------------------------------------------------------------------------------------
% Check number of foreground and background fitting functions
% ----------------------------------------------------------------------------------------------------------------
% Foreground function:
[ok,mess,func]=function_handles_parse(func,size(w),local_foreground);
if ~ok
    [ok,mess,output]=multifit_error(nop,['Foreground function: ',mess]); return;
end

% The next occurence of a function handle or cell array of function handles will be background function(s), if any
iarg_bkd_func=[];
for i=iarg_fore_func+1:numel(args)
    [ok,mess,bkdfunc]=function_handles_valid(args{i});
    if ok   % if not OK, then assume that no background functions are given
        iarg_bkd_func=i;
        break
    end
end
if isempty(iarg_bkd_func)
    bkd=false;
    if local_background
        bkdfunc=cell(1);
    else
        bkdfunc=cell(size(w));
    end
else
    bkd=true;
    [ok,mess,bkdfunc]=function_handles_parse(bkdfunc,size(w),local_background);
    if ~ok
        [ok,mess,output]=multifit_error(nop,['Background function: ',mess]); return;
    end
end

% Check there is a foreground or a background function for every dataset
% (If global function, then there will already be a function handle, so the only case to consider is
% local foreground and local background)
if local_foreground && local_background
    for i=1:numel(func)
        if isempty(func{i}) && isempty(bkdfunc{i})
            [ok,mess,output]=multifit_error(nop,'A fit function must be defined for each data set'); return;
        end
    end
end


% ----------------------------------------------------------------------------------------------------------------
% Check function arguments
% ----------------------------------------------------------------------------------------------------------------

% Get number of foreground and background arguments
if ~bkd
    nfore_args=numel(args)-iarg_fore_func;
    nbkd_args=0;
else
    nfore_args=iarg_bkd_func-1-iarg_fore_func;
    nbkd_args=numel(args)-iarg_bkd_func;
end


% Check that foreground fitting function parameter list has the correct form:
if nfore_args>=1
    [ok,mess,np,pin]=plist_parse(args{iarg_fore_func+1},func);
    if ~ok; [ok,mess,output]=multifit_error(nop,['Foreground fitting function(s): ',mess]); return; end
else
    [ok,mess,output]=multifit_error(nop,'Must give foreground function(s) parameters'); return;
end

% Check background pin have correct form:
if bkd
    if nbkd_args>=1
        [ok,mess,nbp,bpin]=plist_parse(args{iarg_bkd_func+1},bkdfunc);
        if ~ok; [ok,mess,output]=multifit_error(nop,['Background fitting function(s): ',mess]); return; end
    else
        [ok,mess,output]=multifit_error(nop,'Must give background function(s) parameters'); return;
    end
else
    nbp=zeros(size(w));
    bpin=cell(size(w));
end


% ----------------------------------------------------------------------------------------------------------------
% Check optional arguments that control which parameters are free, which are bound
% ----------------------------------------------------------------------------------------------------------------

% Check foreground function(s)
isforeground=true;
ilo=iarg_fore_func+2;   % The first argument was pin, so skip over that
ihi=iarg_fore_func+nfore_args;
[ok,mess,pfree,pbind]=function_optional_args_parse(isforeground,np,nbp,args{ilo:ihi});
if ~ok
    [ok,mess,output]=multifit_error(nop,mess); return;
end

% Check background function(s)
isforeground=false;
if bkd
    ilo=iarg_bkd_func+2;   % The first argument was bpin, so skip over that
    ihi=iarg_bkd_func+nbkd_args;
    [ok,mess,bpfree,bpbind]=function_optional_args_parse(isforeground,np,nbp,args{ilo:ihi});
    if ~ok
        [ok,mess,output]=multifit_error(nop,mess); return;
    end
else
    [ok,mess,bpfree,bpbind]=function_optional_args_parse(isforeground,np,nbp);  % OK output guaranteed
end

% ========================================================================
% Return if just checking the parsing of the functions and their arguments
% ------------------------------------------------------------------------
if options.parsefunc_
    ok=true;
    mess='';
    output={iarg_fore_func, func, pin, pfree, pbind, iarg_bkd_func, bkdfunc, bpin, bpfree, bpbind, numel(args)};
    return
end
% ========================================================================

% Check consistency between the free parameters and all the bindings
% (Do this now to isolate syntax problems before potentially expensive calculation of mask arrays.
% Will have to repeat this check after masking because if some data sets are entirely masked then
% some or all free parameters will no longer affect chi-square.)
[ok,mess,pf]=ptrans_initialise(pin,pfree,pbind,bpin,bpfree,bpbind);

if ~ok || (fitting && isempty(pf)) % inconsistency, or the intention is to fit but there are no free parameters
    [ok,mess,output]=multifit_error(nop,mess); return;
end


% ----------------------------------------------------------------------------------------------------------------
% Check masking values:
% ----------------------------------------------------------------------------------------------------------------
% If masking options are a cell array, then must be either scalar (in which case they apply to all input datasets) or have
% shape equal to the input data array. Otherwise, will appy to all datasets

if ~isempty(options.keep)
    xkeep=options.keep;
    if ~iscell(xkeep), xkeep={xkeep}; end  % make a single cell
    if ~(isscalar(xkeep) || isequal(size(w),size(xkeep)))
        mess='''keep'' option must provide a single entity defining keep ranges, or a cell array of entities with same size as data source';
        [ok,mess,output]=multifit_error(nop,mess); return;
    end
    if isscalar(xkeep), xkeep=repmat(xkeep,size(w)); end
else
    xkeep=cell(size(w));     % empty cell array of correct size, for later convenience
end


if ~isempty(options.remove)
    xremove=options.remove;
    if ~iscell(xremove), xremove={xremove}; end  % make a single cell, for later convenience
    if ~(isscalar(xremove) || isequal(size(w),size(xremove)))
        mess='''remove'' option must provide a single entity defining remove ranges, or a cell array of entities with same size as data source';
        [ok,mess,output]=multifit_error(nop,mess); return;
    end
    if isscalar(xremove), xremove=repmat(xremove,size(w)); end
else
    xremove=cell(size(w));   % empty cell array of correct size, for later convenience
end


if ~isempty(options.mask)
    msk=options.mask;
    if ~iscell(msk), msk={msk}; end  % make a single cell, for later convenience
    if ~(isscalar(msk) || isequal(size(w),size(msk)))
        mess='''mask'' option must provide a single mask, or a cell array of masks with same size as data source';
        [ok,mess,output]=multifit_error(nop,mess); return;
    end
    if isscalar(msk), msk=repmat(msk,size(w)); end
else
    msk=cell(size(w));     % empty cell array of correct size, for later convenience
end


% ----------------------------------------------------------------------------------------------------------------
% Get initial data points - mask out all the points not needed for the fit
% ----------------------------------------------------------------------------------------------------------------
% Accumulate the mask array for later use.
% Needs a method sigvar_get that also returns the mask file of points that can be ignored

wmask=w;  % hold the input data - the memory penalty is only the cost of a bunch of pointers
nodata=true(size(w));
for i=1:numel(w)
    if numel(w)==1, data_id='Dataset:'; else data_id=['Dataset ',arraystr(size(w),i),':']; end
    if xye(i)    % xye triple
        [msk{i},ok,mess]=mask_points_xye(w{i}.x,xkeep{i},xremove{i},msk{i});
        if ok && ~isempty(mess) && options.list~=0
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return;
        end
        [msk{i},ok,mess]=mask_for_fit_xye(w{i}.x,w{i}.y,w{i}.e,msk{i}); % accumulate bad points (y=NaN, zero error bars etc.) to the mask array
        if ok && ~isempty(mess) && options.list~=0
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return;
        end
        for idim=1:numel(w{i}.x)
            wmask{i}.x{idim}=w{i}.x{idim}(msk{i});
        end
        wmask{i}.y=w{i}.y(msk{i});
        wmask{i}.e=w{i}.e(msk{i});
        if any(msk{i}(:)), nodata(i)=false; end
        
    else % a different data object
        if ismethod(w{i},'mask_points')
            [msk{i},ok,mess]=mask_points(w{i},'keep',xkeep{i},'remove',xremove{i},'mask',msk{i});
        else
            [msk{i},ok,mess]=mask_points_xye(sigvar_getx(w{i}),xkeep{i},xremove{i},msk{i});
        end
        if ok && ~isempty(mess) && options.list~=0
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return;
        end   % display warning messages
        [ytmp,vtmp,msk_null]=sigvar_get(w{i});
        [msk{i},ok,mess]=mask_for_fit_xye({},ytmp,vtmp,(msk{i}&msk_null)); % accumulate bad points (y=NaN, zero error bars etc.) to the mask array
        if ok && ~isempty(mess) && options.list~=0
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            [ok,mess,output]=multifit_error(nop,[data_id,mess]); return;
        end   % display warning messages
        wmask{i}=mask(w{i},msk{i}); % 24 Jan 2009: don't think we'll need to keep msk{i}, but do so for moment, for sake of symmetry
        if any(msk{i}(:)), nodata(i)=false; end
        
    end
end


% ----------------------------------------------------------------------------------------------------------------
% Fix unbound free parameters that cannot have any effect on chi-squared because all data has been masked for that element of w
% ----------------------------------------------------------------------------------------------------------------
[ok,mess,pf,p_info]=ptrans_initialise(pin,pfree,pbind,bpin,bpfree,bpbind,nodata);

if ~ok  % inconsistency
    [ok,mess,output]=multifit_error(nop,mess); return;
else    % consistent, but may be no free parameters
    if fitting
        if ~isempty(pf)
            if ~isempty(mess)     % still one or more free parameters, but print message if there is one
                disp(' ')
                disp('********************************************************************************')
                disp(['WARNING: ',mess])
                disp('********************************************************************************')
                disp(' ')
            end
        else                % no free parameters, so return with error
            [ok,mess,output]=multifit_error(nop,mess); return;
        end
    else                    % the intention is to evaluate the function, but print the warning if there is one
        if ~isempty(mess)
            disp(['WARNING: ',mess])
        end
    end
end


% ----------------------------------------------------------------------------------------------------------------
% Perform the fit, evaluation or chisqr calculation (or any combination, as requested)
% ----------------------------------------------------------------------------------------------------------------

% Perform fit, if requested
if fitting || eval_chisqr
    if ~isempty(init_func)
        [ok,mess]=init_func(wmask);
        if ~ok, [ok,mess,output]=multifit_error(nop,['Preprocessor function: ',mess]); return, end
    end
    [p_best,sig,cor,chisqr_red,converged,ok,mess]=multifit_lsqr(wmask,xye,func,bkdfunc,pin,bpin,pf,p_info,options.list,options.fitcontrolparameters,fitting);
    if ~ok, [ok,mess,output]=multifit_error(nop,mess); return, end
else
    p_best=pf;              % Need to have the size of number of free parameters to be useable with p_info
    sig=zeros(1,numel(pf)); % Likewise
    cor=zeros(numel(pf));   % Set to zero, as no fitting done
    chisqr_red=0;           % If do not want to use multifit_lsqr because of unwanted checks and overheads
    converged=false;        % didn't fit, so set to false
end
    
% Evaluate the functions at the fitted parameter values / input parameter requests with ratios properly resolved)
% On the face of it, it should not be necessary to re-evaluate the function, as this will have been done in multifit_lsqr.
% However, there are two reasons why we perform an independent final function evaluation:
% (1) We may want to evaluate the output object for the whole function, not just the fitted points.
% (2) The evaluation of the function inside multifit_lsqr retains only the calculated values at the data points
%     used in the evaluation of chi-squared; the evaluation of the output object(s) may require other fields to be
%     evaluated. For example, when fitting Horace sqw objects, the signal for each of the individual pixels needs to
%     be recomputed.
% If the calculated objects were retained after each iteration, rather than just the values at the data points, then
% it would be possible to use the stored values to avoid this final recalculation for the case of 
% options.selected==true. We could also avoid the second evaluation in the case of eval_chisqr==true.

if options.selected
    if ~isempty(init_func)
        [ok,mess]=init_func(wmask);
        if ~ok, [ok,mess,output]=multifit_error(nop,['Preprocessor function: ',mess]); return, end
    end
    wout=multifit_func_eval(wmask,xye,func,bkdfunc,pin,bpin,p_best,p_info,eval_foreground,eval_background);
    for i=1:numel(wout) % must expand the calculated values into the unmasked x-y-e triple - may be neater way to do this
        if xye(i)
            wout{i}.x=w{i}.x;
            ytmp=wout{i}.y; etmp=wout{i}.e;
            wout{i}.y=NaN(size(w{i}.y)); wout{i}.y(msk{i})=ytmp;
            wout{i}.e=zeros(size(w{i}.e)); wout{i}.e(msk{i})=etmp;
        end
    end
else
    if ~isempty(init_func)
        [ok,mess]=init_func(w);
        if ~ok, [ok,mess,output]=multifit_error(nop,['Preprocessor function: ',mess]); return, end
    end
    wout=multifit_func_eval(w,xye,func,bkdfunc,pin,bpin,p_best,p_info,eval_foreground,eval_background);
end


% ----------------------------------------------------------------------------------------------------------------
% Fill ouput parameters
% ----------------------------------------------------------------------------------------------------------------
% Turn output data into form of input data
wout = repackage_output_datasets(wout, single_data_arg, cell_data, xye, xye_xarray);

% Fit parameters:
fitdata = repackage_output_parameters (p_best, sig, cor, chisqr_red, converged, p_info, bkd);

% Pack the output
ok=true;
mess='';
output={wout,fitdata};

% Cleanup multifit status
if matlab_version_num<7.06     % prior to R2008a: does not automatically call cleanup (see start of this function)
    multifit_cleanup
end

%=================================================================================================================
function multifit_cleanup
% Cleanup multfit
multifit_store_state
multifit_lsqr_func_eval
