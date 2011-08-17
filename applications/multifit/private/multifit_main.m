function [ok,mess,output] = multifit_main(varargin)
% This is a private function that is called by the multifit gateway functions
%   >> [ok,mess,wfit,fitdata] = multifit_main (...)
%   
%   ok      True if no problems, false otherwise
%   mess    If ok, then empty; if ~ok, then contains informative error message
%   output  Cell array with output:
%           - if input arguments have requested fitting or simulation of function
%               output = {wout, fitdata}    % see below for contents
%           - if input arguments have requested parsing of functions, then
%               output = {pos,func,plist,bpos,bfunc,bplist}
%
% The following documentation should be synchronised with that for the multifit
% gateway function multifit.m
%
% -------------------------------------------------------------------------------------------------
% Find best fit of a parametrised function to data. Works for arbitrary 
% number of dimensions. Various keywords control output.
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
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = multifit (..., keyword, value, ...)
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%       'evaluate'  evaluate at the initial parameter values (convenient to test starting values)
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
%  A final useful keyword is:
%
%  'evaluate'   Evaluate the fitting function at the initial parameter values only. Useful for
%           checking the validity of starting parameters
%
%
% Output:
% =======
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%           Has the same form as the input data. The only exception is if x,y,e were given as
%          three separate arrays, only ycalc is returned.
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
%
%
% Parsing input parameters
% ========================
% A feature no documented above is one to locate the presence of the global fitting function
% and any background functions, withut actually fitting. This has a use, for example, when
% repackaging the input for a custom call to multifit.
%
% 'parsefunc_'  if true, then return the following

% Find number of return arguments
narg=nargout-3;

% Set defaults:
arglist = struct('fitcontrolparameters',[0.0001 30 0.0001],...
                 'list',0,'keep',[],'remove',[],'mask',[],'selected',0,'evaluate',0,'parsefunc_',0);
flags = {'selected','evaluate','parsefunc_'};

% Parse parameters:
[args,options] = parse_arguments(varargin,arglist,flags);

if numel(args)<1
    ok=false;
    mess='Check number of input arguments';
    parsefunc=[];
    varargout=cell(1,narg);
    return
end

% Determine if just parsing the function handles and parameters
if options.parsefunc_
    parsefunc=true;
else
    parsefunc=false;
end

% Find fitting functions
% ----------------------
% Find a scalar function handle - that will be the global function
iarg_global_func=[];
for i=1:numel(args)
    if isa(args{i},'function_handle')
        if isscalar(args{i})
            iarg_global_func=i;
            func=args{iarg_global_func};
        else
            ok=false;
            mess='Fitting function handle must be a scalar';
            varargout=cell(1,narg);
            return
        end
        break
    end
end
if isempty(iarg_global_func)
    ok=false;
    mess='Must provide handle to fitting function';
    varargout=cell(1,narg);
    return
end


% Check nature of data to be fitted
% ---------------------------------
% If the data is an array or cell array of structures, then they have to be x-y-e triples.
% Otherwise, any class or cell array of classes is permitted - we'll make the routine 
% as general as possible - so long as the fitting function is a method of the class. 
% The restriction on structures is only because this will be the most common form of data
% entry other than specialised classes, so it is better to enforce a rigid format to
% prevent common input errors.
%
% Will have at the end of this heading
%   w                   input data packaged as cell array
% and some variables that enable the form of the data to be unpacked
%   xye                 logical array, size(w): indicating which data are x-y-e triples
%   xye_xarray          logical array, size(w): indicates if x values formed a single numeric array
%   single_data_arg     logical: false if x,y,e were separate arguments
%   cell_data           logical: true if data was a cell array


if iarg_global_func==2
    single_data_arg=true;
    w=args{1};
    if iscell(w)
        % Any element that is a structure must be a scalar x-y-e triple
        ndim_xye=NaN(size(w));
        for i=1:numel(w)
            if isstruct(w{i})
                if isscalar(w{i})
                    [ok,mess,ndim_xye(i)]=is_struct_xye(w{i});
                    if ~ok
                        ok=false;
                        mess=['Data cell array element ',arraystr(size(w),i),' is a structure : ',mess];
                        varargout=cell(1,narg);
                        return
                    end
                else
                    ok=false;
                    mess=['Data cell array element ',arraystr(size(w),i),' invalid: is an array of structures'];
                    varargout=cell(1,narg);
                    return
                end
            else
                if ~parsefunc   % don't check validity of method if just testing the parsing
                    tmp=functions(func);    % see Matlab documentation about using this function with caution
                    if ~ismethod(w{i},tmp.function)
                        ok=false;
                        mess=['Data cell array element ',arraystr(size(w),i),': fit function is not a method of this object'];
                        varargout=cell(1,narg);
                        return
                    end
                end
            end
        end
    elseif isstruct(w)
        % Array of structures permitted, if each element is an x-y-e triple
        [ok,mess,ndim_xye]=is_struct_xye(w);
        if ~ok
            varargout=cell(1,narg);
            return
        end
    else
        % Could be an array of objects
        ndim_xye=NaN(size(w));  % NaN to indicate was not an x-y-e triple
        if ~parsefunc   % don't check validity of method if just testing the parsing
            tmp=functions(func);    % see Matlab documentation about using this function with caution
            if ~ismethod(w,tmp.function)
                ok=false;
                mess='Data object: fit function is not a method of this object';
                varargout=cell(1,narg);
                return
            end
        end
    end
elseif iarg_global_func==4
    % Could be x-y-e triple, so package as structure and check validity
    single_data_arg=false;
    w.x=args{1};
    w.y=args{2};
    w.e=args{3};
    [ok,mess,ndim_xye]=is_struct_xye(w);
    if ~ok
        varargout=cell(1,narg);
        return
    end
else
    ok=false;
    mess='Syntax of data argument(s) is invalid';
    varargout=cell(1,narg);
    return
end

% Repackage the data in a standard form: a cell array where each element is
% either an x-y-e triple with x a cell array of arrays, one for each x-coordinate
% or an object for which func is a method. Do this for three reasons:
%  - do not have to repackage the x in x-y-e triple every time the function is evaluated
%    in the least-squares algorithm
%  - a cell array prevents any confusion with a method of an object
%  - makes the function evaluation algorithm less laden with if...end branches

if ~iscell(w)
    cell_data=false;  % flag that indicates if input data was not a cell array
    w=num2cell(w);
else
    cell_data=true;
end

xye=false(size(w));     % logical array, true where data is x-y-e triple
xye(isfinite(ndim_xye))=true;
xye_xarray=false(size(w));
for i=1:numel(w)
    if isfinite(ndim_xye(i)) && ~iscell(w{i}.x)
        % must be a valid xye triple, as otherwise element is ndim_xye(i)==NaN, and the x-coords are in a single array
        xye_xarray(i)=true;
        if ndim_xye(i)>1
            w{i}.x=squeeze(num2cell(w{i}.x,1:(ndims(w{i}.x)-1)));    % separate the dimensions into cells
        else
            w{i}.x={w{i}.x};    % just make the array a single cell
        end
    end
end




% Determine if background(s) given
% --------------------------------
% Find a function handle, or cell array of function handles
% If present and correct, then this block will produce a cell array of
% function handles of the same size as the data array. Missing background functions
% will be empty elements of bkdfunc
bkd=false;
bkdfunc=cell(size(w));
if length(args)>iarg_global_func
    iarg_bkd_func=[];
    for i=iarg_global_func+1:numel(args)
        if is_function_handles(args{i})
            iarg_bkd_func=i;
            bkd=true;
            if isa(args{i},'function_handle')
                bkdfunc=repmat({args{i}},size(w));
            else
                if isequal(size(args{i}),size(w))
                    bkdfunc=args{i};
                elseif isscalar(args{i})
                    bkdfunc=repmat({args{i}{1}},size(w));
                else
                    ok=false;
                    mess='Background function handle parameter must be scalar or have same size as data array';
                    varargout=cell(1,narg);
                    return
                end
            end
            break
        end
    end
end


% Check function arguments
% -------------------------------
if ~bkd
    nglobal_args=numel(args)-iarg_global_func;
else
    nglobal_args=iarg_bkd_func-1-iarg_global_func;
    nbkd_args=numel(args)-iarg_bkd_func;
end

% Check that pin has the correct form:
if nglobal_args>=1
    pin=args{iarg_global_func+1};
    [ok,np]=parameter_valid(pin);
    if ~ok
        mess='Check that the fitting parameter list is valid';
        varargout=cell(1,narg);
        return
    end
else
    ok=false;
    mess='Must give fitting function parameters';
    varargout=cell(1,narg);
    return
end

% Check background pin have correct form:
if bkd
    if nbkd_args>=1
        % Check form of argument
        [ok,mess,nbp,bpin]=bkd_parameter_valid(args{iarg_bkd_func+1},bkdfunc);
        if ~ok
            varargout=cell(1,narg);
            return
        end
    else
        ok=false;
        mess='Must give background function(s) parameters';
        varargout=cell(1,narg);
        return
    end
else
    nbp=zeros(size(w));
    bpin=cell(size(w));
end

% -------------------------------------------------------------------------------------------------
% Return if checking the parsing of the functions and their arguments
if parsefunc
    ok=true;
    mess='';
    output=cell(1,6);
    output{1}=iarg_global_func;
    output{2}=func;
    output{3}=pin;
    if bkd
        output{4}=iarg_bkd_func;
    else
        output{4}=[];
    end
    output{5}=bkdfunc;
    output{6}=bpin;
    return
end
% -------------------------------------------------------------------------------------------------

% Check optional global arguments
if nglobal_args==1  % no optional arguments
    [ok,mess,pfree]=pfree_valid_syntax([],np);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    [ok,mess,ipbind,ipfree,ifuncbind,rpbind]=pbind_valid_syntax({},np,nbp,0);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    
elseif nglobal_args==2  % must be pfree
    [ok,mess,pfree]=pfree_valid_syntax(args{iarg_global_func+2},np);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    [ok,mess,ipbind,ipfree,ifuncbind,rpbind]=pbind_valid_syntax({},np,nbp,0);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    
elseif nglobal_args==3  % must be pfree followed by pbind
    [ok,mess,pfree]=pfree_valid_syntax(args{iarg_global_func+2},np);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    [ok,mess,ipbind,ipfree,ifuncbind,rpbind]=pbind_valid_syntax(args{iarg_global_func+3},np,nbp,0);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    
else
    ok=false;
    mess='Too many optional arguments for fitting function';
    varargout=cell(1,narg);
    return
end

% Check optional background arguments
if bkd
    if nbkd_args==1  % no optional arguments
        [ok,mess,bpfree]=bkd_pfree_valid_syntax({},nbp);
        if ~ok
            varargout=cell(1,narg);
            return
        end
        [ok,mess,ibpbind,ibpfree,ibfuncbind,rbpbind]=bkd_pbind_valid_syntax({},np,nbp);
        if ~ok
            varargout=cell(1,narg);
            return
        end
    elseif nbkd_args==2  % must be bpfree
        [ok,mess,bpfree]=bkd_pfree_valid_syntax(args{iarg_bkd_func+2},nbp);
        if ~ok
            varargout=cell(1,narg);
            return
        end
        [ok,mess,ibpbind,ibpfree,ibfuncbind,rbpbind]=bkd_pbind_valid_syntax({},np,nbp);
        if ~ok
            varargout=cell(1,narg);
            return
        end
        
    elseif nbkd_args==3  % must be bpfree followed by bpbind
        [ok,mess,bpfree]=bkd_pfree_valid_syntax(args{iarg_bkd_func+2},nbp);
        if ~ok
            varargout=cell(1,narg);
            return
        end
        [ok,mess,ibpbind,ibpfree,ibfuncbind,rbpbind]=bkd_pbind_valid_syntax(args{iarg_bkd_func+3},np,nbp);
        if ~ok
            varargout=cell(1,narg);
            return
        end
        
    else
        ok=false;
        mess='Too many optional arguments for fitting function';
        varargout=cell(1,narg);
        return
    end
else % get values for absent background that will work in ptrans_create
    [ok,mess,bpfree]=bkd_pfree_valid_syntax({},nbp);
    if ~ok
        varargout=cell(1,narg);
        return
    end
    [ok,mess,ibpbind,ibpfree,ibfuncbind,rbpbind]=bkd_pbind_valid_syntax({},np,nbp);
    if ~ok
        varargout=cell(1,narg);
        return
    end
end


% Check consistency between the free parameters and all the bindings
% (do this before considering further complications if all datapoints in one or more data objects are masked out
%  in order to isolate syntax problems before expensive calculation of mask arrays)
[ok,mess,pf,p_info]=ptrans_create(pin,pfree,ipbind,ipfree,ifuncbind,rpbind,...
                                  bpin,bpfree,ibpbind,ibpfree,ibfuncbind,rbpbind);
if ~ok
    varargout=cell(1,narg);
    return
elseif isempty(pf) && ~options.evaluate
    ok=false;
    mess='No free parameters to fit';
    varargout=cell(1,narg);
    return
end


% Check masking values:
% ------------------------
% If masking options are a cell array, then must be either scalar (in which case they apply to all input datasets) or have
% shape equal to the input data array. Otherwise, will appy to all datasets

if ~isempty(options.keep)
    xkeep=options.keep;
    if ~iscell(xkeep), xkeep={xkeep}; end  % make a single cell
    if ~(isscalar(xkeep) || isequal(size(w),size(xkeep)))
        ok=false;
        mess='''keep'' option must provide a single entity defining keep ranges, or a cell array of entities with same size as data source';
        varargout=cell(1,narg);
        return
    end
    if isscalar(xkeep), xkeep=repmat(xkeep,size(w)); end
else
    xkeep=cell(size(w));     % empty cell array of correct size, for later convenience
end


if ~isempty(options.remove)
    xremove=options.remove;
    if ~iscell(xremove), xremove={xremove}; end  % make a single cell, for later convenience
    if ~(isscalar(xremove) || isequal(size(w),size(xremove)))
        ok=false;
        mess='''remove'' option must provide a single entity defining remove ranges, or a cell array of entities with same size as data source';
        varargout=cell(1,narg);
        return
    end
    if isscalar(xremove), xremove=repmat(xremove,size(w)); end
else
    xremove=cell(size(w));   % empty cell array of correct size, for later convenience
end


if ~isempty(options.mask)
    msk=options.mask;
    if ~iscell(msk), msk={msk}; end  % make a single cell, for later convenience
    if ~(isscalar(msk) || isequal(size(w),size(msk)))
        ok=false;
        mess='''mask'' option must provide a single mask, or a cell array of masks with same size as data source';
        varargout=cell(1,narg);
        return
    end
    if isscalar(msk), msk=repmat(msk,size(w)); end
else
    msk=cell(size(w));     % empty cell array of correct size, for later convenience
end


% Get initial data points - mask out all the points not needed for the fit
% -------------------------------------------------------------------------
% Accumulate the mask array for later use.
% Needs a method sigvar_get that also returns the mask file of points that can be ignored

wmask=w;  % hold the input data - the memory penalty is only the cost of a bunch of pointers
nodata=true(size(w));
for i=1:numel(w)
    if numel(w)==1, data_id='Dataset:'; else data_id=['Dataset ',arraystr(size(w),i),':']; end
    if xye(i)    % xye triple
        [msk{i},ok,mess]=mask_points_xye(w{i}.x,xkeep{i},xremove{i},msk{i});
        if ok && ~isempty(mess)
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            mess=[data_id,mess];
            varargout=cell(1,narg);
            return
        end
        [msk{i},ok,mess]=mask_for_fit_xye(w{i}.x,w{i}.y,w{i}.e,msk{i}); % accumulate bad points (y=NaN, zero error bars etc.) to the mask array
        if ok && ~isempty(mess)
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            mess=[data_id,mess];
            varargout=cell(1,narg);
            return
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
        if ok && ~isempty(mess)
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            mess=[data_id,mess];
            varargout=cell(1,narg);
            return
        end   % display warning messages
        [ytmp,vtmp,msk_null]=sigvar_get(w{i});
        [msk{i},ok,mess]=mask_for_fit_xye({},ytmp,vtmp,(msk{i}&msk_null)); % accumulate bad points (y=NaN, zero error bars etc.) to the mask array
        if ok && ~isempty(mess)
            display_mess(data_id,mess)  % display warning messages
        elseif ~ok
            mess=[data_id,mess];
            varargout=cell(1,narg);
            return
        end   % display warning messages
        wmask{i}=mask(w{i},msk{i}); % 24 Jan 2009: don't think we'll need to keep msk{i}, but do so for moment, for sake of symmetry
        if any(msk{i}(:)), nodata(i)=false; end
        
    end
end


% Fix unbound free parameters that cannot have any effect on chi-squared because all data has been masked for that element of w
% ------------------------------------------------------------------------------------------------------------------------------
[ok,mess,pf,p_info]=ptrans_create(pin,pfree,ipbind,ipfree,ifuncbind,rpbind,...
                                  bpin,bpfree,ibpbind,ibpfree,ibfuncbind,rbpbind,nodata);
if ~ok
    varargout=cell(1,narg);
    return
elseif isempty(pf)
    if ~options.evaluate
        ok=false;
        mess='No free parameters to fit';
        varargout=cell(1,narg);
        return
    else
        disp('WARNING: No free parameters to fit')
    end
end


% Perform the fit
% -----------------
np=p_info.np;
nbp=p_info.nbp;

% Perform fit, if requested
if ~options.evaluate   
    [p_best,sig,cor,chisqr_red]=multifit_lsqr(wmask,xye,func,bkdfunc,pin,bpin,pf,p_info,options.list,options.fitcontrolparameters);
else
    p_best=pf;              % Need to have the size of number of free parameters to be useable with p_info
    sig=zeros(size(pf));    % Likewise
    cor=eye(numel(pf));     % But this we can set to empty, as no fitting done
    chisqr_red=0;           % Ideally should calculate, but do not want to use multifit_lsqr because of unwanted checks and overheads
end
    
% Evaluate the functions at the fitted parameter values / input parameter requests with ratios properly resolved)
if options.selected
    wout=multifit_func_eval(wmask,xye,func,bkdfunc,pin,bpin,p_best,p_info);
    for i=1:numel(wout) % must expand the calculated values into the unmasked x-y-e triple - may be neater way to do this
        if xye(i)
            wout{i}.x=w{i}.x;
            ytmp=wout{i}.y; etmp=wout{i}.e;
            wout{i}.y=NaN(size(w{i}.y)); wout{i}.y(msk{i})=ytmp;
            wout{i}.e=zeros(size(w{i}.e)); wout{i}.e(msk{i})=etmp;
        end
    end
else
    wout=multifit_func_eval(w,xye,func,bkdfunc,pin,bpin,p_best,p_info);
end


% Fill ouput parameters
% ------------------------
% Turn output data into form of input data
if single_data_arg
    % Convert x coordinates back to array, if xye triple and songle array input
    % *** could make more efficient if for options.selected=false just pick up the input x coordinates
    for i=1:numel(wout)
        if xye(i) && xye_xarray(i)
            nx=numel(wout{i}.x);   % is a cell array
            if nx>1
                wout{i}.x=squeeze(nx+1,cat(wout{i}.x{:}));
            else
                wout{i}.x=wout{i}.x{1};
            end
        end
    end
    % Convert output to array, if input wa array
    if ~cell_data
        if isstruct(wout{1})
            wout=cell2mat(wout);
        else
            wout=cell2mat_obj(wout);    % for some reason, cell2mat doesn't work with arbitrary objects, so fix-up
        end
    end
else
    wout=wout{1}.y;         % if x,y,e supplied as separate arguments, then just return y array.
end

% Create fit summary
% (Give default names of the parameters for backwards compatibility with function calls to original 'fit' function
%  No longer try assuming form of mfit function and catch in case not, because the line
%    try, [dummy1,dummy2,pnames] = func(x{:}, p{1}, 1); catch...
%  could invoke a very lengthy calculation)

[fitdata.p,bp_tmp]=ptrans(p_best,p_info);
[fitdata.sig,bsig_tmp]=ptrans_sig(sig,p_info);
if bkd
    fitdata.bp=bp_tmp;
    fitdata.bsig=bsig_tmp;
end
fitdata.corr=cor;
fitdata.chisq=chisqr_red;

fitdata.pnames=cell(1,np);
for ip=1:np, fitdata.pnames{ip}=['p',num2str(ip)]; end
if bkd
    fitdata.bpnames=cell(size(nbp));
    for i=1:numel(nbp)
        fitdata.bpnames{i}=cell(1,nbp(i));
        for ip=1:nbp(i), fitdata.bpnames{i}{ip}=['p',num2str(ip)]; end
    end
end

% Pack the output
ok=true;
mess='';
output=cell(1,2);
output{1}=wout;
output{2}=fitdata;
