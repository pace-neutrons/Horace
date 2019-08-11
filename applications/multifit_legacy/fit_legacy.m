function [wout,fitdata,ok,mess] = fit_legacy(varargin)
% Fits a function to a dataset, with an optional background function.
%
% The data to be fitted can be a set or sets of of x,y,e arrays, or an
% object or array of objects of a class. [Note: if you have written your own
% class, there are some required methods for this fit function to work.
% See notes at the end of this help]
%
%
% A background function can be added to the fit function.
% If passed an array of datasets, then each dataset is fitted independently.
%
%
% Fit several datasets in succession to a given function:
% -------------------------------------------------------
%   >> [wout, fitdata] = fit_legacy (x, y, e, func, pin)
%   >> [wout, fitdata] = fit_legacy (x, y, e, func, pin, pfree)
%   >> [wout, fitdata] = fit_legacy (x, y, e, func, pin, pfree, pbind)
%
%   >> [wout, fitdata] = fit_legacy (w, func, pin)
%   >> [wout, fitdata] = fit_legacy (w, func, pin, pfree)
%   >> [wout, fitdata] = fit_legacy (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background function added to the function:
% --------------------------------------------------------
%   >> [wout, fitdata] = fit_legacy (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit_legacy (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit_legacy (..., bkdfunc, bpin, bpfree, bpbind)
%
%
% Additional keywords controlling the fit:
% ----------------------------------------
% You can alter the range of data to fit, alter convergence criteria,
% verbosity of output etc. with keywords, some of which need to be paired
% with input values, some of which are just logical flags:
%
%   >> [wout, fitdata] = fit_legacy (..., keyword, value, ...)
%
% Keywords that are logical flags (indicated by *) take the value true
% if the keyword is present, or their default if not.
%
%     Select points to fit:
%       'keep'          Range of x values to keep.
%       'remove'        Range of x values to remove.
%       'mask'          Logical mask array (true for those points to keep).
%   *   'select'        If present, calculate output function only at the
%                      points retained for fitting.
%
%     Control fit and output:
%       'fit'           Alter convergence criteria for the fit etc.
%       'list'          Level of verbosity of output during fitting (0,1,2...).
%
%     Evaluate at initial parameters only (i.e. no fitting):
%   *   'evaluate'      Evaluate function at initial parameter values only
%                      without doing a fit. Performs an argument check as well.
%                     [Default: false]
%   *   'foreground'    Evaluate foreground function only (if 'evaluate' is
%                      not set then ignored).
%   *   'background'    Evaluate background function only (if 'evaluate' is
%                      not set then ignored).
%   *   'chisqr'        Evaluate chi-squared at the initial parameter values
%                      (ignored if 'evaluate' not set).
%
%   EXAMPLES:
%   >> [wout, fitdata] = fit_legacy(...,'keep',[0.4,1.8],'list',2)
%
%   >> [wout, fitdata] = fit_legacy(...,'select')
%
% If unable to fit, then the program will halt and display an error message.
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = fit_legacy (...)
%
%
%------------------------------------------------------------------------------
% Description in full
%------------------------------------------------------------------------------
% Input:
% ======
%   Data to be fitted:
%      Single data set only:
%       x   Coordinates of the data points: one of
%           - Vector of x values (1D data) (column or row vector)
%
%           - Two-dimensional array of x coordinates size [npnts,ndims]
%             where npnts is the number of points, and ndims the number
%             of dimensions
%
%           - More generally, an array of any size whose outer dimension
%             gives the coordinate dimension i.e. x(:,:,...:,1) is the array
%             of coordinates along axis 1, x(:,:,...:,2) are those along
%             axis 2 ... to x(:,:,...:,n) are those along the nth axis.
%
%           - A cell array of length n, where x{i} gives the coordinates
%             of all the points on the ith dimension. The arrays can have
%             any size, but they must all have the same size.
%
%       y   Array of the of data values at the points defined by x. Must
%           have the same size as x(:,:,...:,1) if x is an array, or
%           of x{i} if x is a cell array.
%
%       e   Array of the corresponding error bars. Must have same size as y.
%
%   Alternatively:
%       w   - A structure with fields w.x, w.y, w.e  where x, y, e are arrays
%             as defined above (this is a single dataset)
%
%           - An array of structures fields w(i).x, w(i).y, w(i).e  where x, y, e
%             are arrays as defined above (this defines multiple dataset)
%
%           - A cell array of structures {w1,w2,...}, each structure with fields
%             w1.x, w1.y, w1.e  etc. which correspond to a single dataset
%
%           - An array of objects to be fitted.
%
%           - A cell array of objects to be fitted. Not all the objects need
%             to be of the same class, so long as the function to be fitted
%             is defined as a method for each of the class types.
%
%   func    A handle to the function to be fitted to each of the datasets.
%           If fitting x,y,e data, or structure(s) with fields w.x,w.y,w.e,
%           then the function must have the form:
%               ycalc = my_function (x1,x2,...,p)
%
%             or, more generally:
%               ycalc = my_function (x1,x2,...,p,c1,c2,...)
%
%             where
%               - x1,x2,... Arrays of x values along first, second,...
%                          dimensions
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%
%             Type >> help gauss2d  or >> help mexpon for examples
%
%           If fitting objects, then if w is an instance of an object or
%           an array of objects, the function or method must have the form:
%               wcalc = my_function (w,p)
%
%             or, more generally:
%               wcalc = my_function (w,p,c1,c2,...)
%
%             where
%               - w         Object on which to evaluate the function
%               - p         A vector of numeric parameters that define the
%                          function (e.g. [A,x0,w] as area, position and
%                          width of a peak)
%               - c1,c2,... Any further arguments needed by the function (e.g.
%                          they could be the filenames of lookup tables)
%             Type >> help gauss2d  or >> help mexpon for examples
%
%           == Advanced use of functions: ==
%           The fitting function can be made of nested functions. The examples
%           below illustrate why this can be useful. The convention that is
%           followed by this least-squares algorithm is to assume that a
%           fitting function with form:
%               my_func1 (w, @my_func2, pcell, c1, c2, ...)
%
%           where pcell is a cell array, will be evaluated as:
%               my_func1 (my_func2(w, pcell{:}), c1, c2, ...)
%
%           == EXAMPLE: Fit a model for S(Q,w) to an sqw object:
%           Suppose we have a function to compute S(Q,w) with standard form:
%               weight = my_sqwfunc (qh, qk, ql, en, p, c1, c2,..)
%
%           where in the general case c1, c2 are some constant parameters
%           needed by the function (e.g. the names of files with lookup
%           tables). Suppose also that there is a method of the sqw object to
%           evaluate this function:
%               wcalc = sqw_eval (w, @my_sqwfunc, {p, c1, c2, ...})
%
%           In that case, the model for S(Q,w) can be fitted by the call:
%               fit (w, @sqw_eval, {@my_sqwfunc, {p, c1, c2,...}})
%
%           == EXAMPLE: Resolution convolution of S(Q,w):
%           Suppose there is a method of sqw class that takes a model for
%           S(Q,w) and convolutes with the resolution function:
%               wres = resconv (w, @my_sqwfunc, {p,c1,c2,...}, res1, res2)
%
%           where res1, res2... are some constant parameters needed to
%           evaluate the resolution function e.g. flight paths in the
%           instrument. In this case, the function call will be:
%               fit (w, @resconv, {@my_sqwfunc, {p, c1, c2,...}, res1, res2})
%
%   pin     Initial function parameter values
%            - If the function takes just a numeric array of parameters, p,
%              then pin contains the initial values, that is, pin is the
%              array [pin(1), pin(2)...]
%
%            - If further parameters are needed by the function, then wrap
%              them as a cell array, that is, pin is the cell array
%               {[pin(1), pin(2)...], c1, c2, ...}
%
%   pfree   [Optional] Indicates which are the free parameters in the fit.
%           e.g. pfree=[1,0,1,0,0] indicates first and third parameters
%           are free, and the 2nd, 4th and 5th are fixed.
%           Default: if pfree is omitted or pfree=[] all parameters are free.
%
%   pbind   [Optional] Cell array that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin.
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%             pbind={1,3}               Parameter 1 is bound to parameter 3.
%
%           Multiple bindings are made from a cell array of cell arrays
%             pbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,[],7.4)        Parameter 1 is bound to parameter 3
%                                      with ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. the foreground
%                                      function rather than the optional
%                                      background function.
%             pbind={1,3,0,7.4}         Same meaning: 0 (or -1) for foreground
%                                      function
%
%           To bind to background function parameters (see below)
%             pbind={1,3,1}             Parameter 1 bound to parameter 3 of
%                                      the background function, in the ratio
%                                      given by the initial values.
%             pbind={1,3,1,3.14}        Give explicit binding ratio.
%
%           EXAMPLE:
%             pbind={{1,3,[],7.4},{4,3,0,0.023},{5,2,1},{6,3,1,3.14}}
%                                       Parameters 1 and 4 bound to parameter
%                                      3, and parameters5 and 6 bound to
%                                      parameters 2 and 3 of the background.
%
%           Note that you cannot bind a parameter to a parameter that is
%           itself bound to another parameter. You can bind to a fixed or free
%           parameter.
%
%
%   Optional background function:
%   -----------------------------
%   bkdfunc A handle to the background function to be fitted to each of the
%           datasets.
%           See the description of the foreground function for details
%
%   bpin    Initial parameter values for the background function.  See the
%           description of the foreground function for details.
%
%   bpfree  Array indicating which parameters are free. See the
%           description of the foreground function for details.
%
%   bpbind  [Optional] Cell array that that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin and bpin.
%           The syntax is the same as for the foreground function:
%
%             bpbind={1,3}              Parameter 1 is bound to parameter 3.
%
%           Multiple bindings are made from a cell array of cell arrays
%             bpbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio, ignoring that determined from bpin:
%             bpbind=(1,3,[],7.4)       Parameter 1 is bound to parameter 3,
%                                      ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. the background
%                                      function rather than the foreground
%                                      function.
%             bpbind={1,3,1,7.4}         Same meaning: 1 for background function
%
%           To bind to foreground function parameters:
%             bpbind={1,3,0}            Parameter 1 bound to parameter 3 of
%                                      the foreground function.
%             bpbind={1,3,0,3.14}       Give explicit binding ratio.
%
%
% Optional keywords:
% ------------------
% Keywords that are logical flags (indicated by *) take the value true
% if the keyword is present, or their default if not.
%
% Select points to fit:
%   'keep'  Array giving ranges along each x-axis to retain for fitting.
%           - If one dimension:
%               [xlo, xhi]
%           - If two dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi]
%           - General case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range to keep can be specified in additional rows:
%               [Range_1; Range_2; Range_3;...; Range_m]
%           where each of the ranges are given in the format above.
%
%
%   'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. 'remove' takes precedence over 'keep'.
%
%   'mask'  Array of ones and zeros, with the same number of elements as the
%           input data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting (1=keep, 0=remove).
%
%
% * 'select' Calculates the returned function values only at the points
%           that were selected for fitting by 'keep', 'remove', 'mask' (and
%           which were not eliminated for having zero error bar). This is
%           useful for plotting the output, as only those points that
%           contributed to the fit will be plotted. [Default: false]
%
% Control fit and output:
%   'fit'   Array of fit control parameters
%           fcp(1)  Relative step length for calculation of partial derivatives
%                   [Default: 1e-4]
%           fcp(2)  Maximum number of iterations [Default: 20]
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if (chisqr_new-chisqr_old) < fcp(3)*chisqr_old
%                   [Default: 1e-3]
%
%   'list'  Numeric code to control output to Matlab command window to monitor
%           status of fit:
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
% Evaluate at initial parameters only (i.e. no fitting):
% * 'evaluate'    Evaluate the fitting function at the initial parameter values
%                without doing a fit. Useful for checking the goodness of
%                starting parameters. Performs an argument check as well.
%                By default, then sum of the foreground and background
%                functions is calculated. [Default: false]
% * 'foreground'  Evaluate foreground function only (if 'evaluate' is
%                not set then ignored).
% * 'background'  Evaluate background function only (if 'evaluate' is
%                not set then ignored).
% * 'chisqr'      Evaluate chi-squared at the initial parameter values
%               (ignored if 'evaluate' not set).
%
%
%   Example:
%   >> [wout, fitdata] = fit_legacy(...,'keep',[0.4,1.8],'list',2)
%
%
% Output:
% =======
%   wout    Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%           wout(i)==w(i) if w is an array of structures or objects, or
%           wout{i}=[] if cell array input).
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then wout=[].
%
% fitdata   Structure with result of the fit for each dataset. The fields are:
%          	p      - Parameter values [Row vector]
%           sig    - Estimated errors of global parameters (=0 for fixed
%                    parameters) [Row vector]
%           bp     - Background parameter values [Row vector]
%        	bsig   - Estimated errors of background (=0 for fixed parameters)
%                    [Row vector]
%       	corr   - Correlation matrix for free parameters
%          	chisq  - Reduced Chi^2 of fit (i.e. divided by
%                                (no. of data points) - (no. free parameters))
%       	converged - True if the fit converged, false otherwise
%           pnames - Parameter names: a cell array (row vector)
%        	bpnames- Background parameter names: a cell array (row vector)
%
%           Single data set input:
%           ----------------------
%           If there was a problem i.e. ok==false, then fitdata=[]
%
%           Array of data sets:
%           -------------------
%           fitdata is an array of structures with the size of the input
%          data array.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%          fitdata(i) will contain dummy information.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%             both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g.
%             the number of free parameters equals or exceeds the number
%             of data points
%
%           Array of data sets:
%           -------------------
%           If an array of input datasets was given, then ok is an array with
%          the size of the input data array.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then ok is scalar and ok==false.
%
%   mess    Error message if ok==false; Empty string if ok==true.
%
%           Array of data sets:
%           -------------------
%           If an array of datasets was given, then mess is a cell array of
%          strings with the same size as the input data array.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then mess is a single character string.
%
%
% EXAMPLES:
% =========
%
% Fit a Gaussian on a linear background:
%
%   >> pin=[20,10,3];   % Initial height, position and standard deviation
%   >> bg=[2,0]         % Initial intercept and gradient of background
%   >> [yfit,fitpar]=fit_legacy(x,y,e,@gauss,pin,@linear_bg,bg)
%
% Remove a portion of the data, and give copious output during the fitting
%
%   >> [yfit,fitpar]=fit_legacy(x,y,e,@gauss,pin,@linear_bg,bg,'remove',[12,14],'list',2)
%
% Fix the position and constrain the width to be a constant multiple of
% the constant part of the linear background:
%
%   >> [yfit,fitpar]=fit_legacy(x,y,e,@gauss,pin,[1,0,1],{3,1,1},@linear_bg,bg)

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   first_line = {'% Fits a function to a dataset, with an optional background function.'}
%   main = true;
%   method = false;
%   synonymous = false;
%
%   multifit=false;
%   func_prefix='fit_legacy';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%
%   custom_keywords = false;
%
% <#doc_beg:> multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_fit_short.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_fit_long.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_fit_examples_1d.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


% Note:
% - In the following it is necessary to call multifit, not multifit_gateway, as the overloaded version of multifit
%  corresponding to an object may be needed (see e.g. IX_dataset_1d, which wraps the user function with a call to func_eval)
% - It is necessary to ensure that any overloaded version of multifit has the full return arguments
%  [wout,fitdata,ok,mess]


if numel(varargin)>1
    for i=1:numel(varargin)
        if isa(varargin{i},'function_handle')
            if i==4
                % x-y-e data is the only possibility; checking internal to multifit will test this
                [wout,fitdata,ok,mess]=multifit(varargin{:});
                if ~ok && nargout<3, error(mess), end

            elseif i==2
                % array or cellarray of datasets (structures or object)
                if iscell(varargin{1})
                    % If cellarray, the elements of the cell array must all be scalar structures or all objects of the same type
                    for id=1:numel(varargin{1})
                        if id==1
                            struct_data=isstruct(varargin{1}{id});
                            obj_data=isobject(varargin{1}{id});
                            if ~((struct_data||obj_data) && numel(varargin{1}{id})==1)
                                wout=[]; fitdata=[]; ok=false; mess='Check form of data to be fitted';
                                if nargout<3, error(mess), else return, end
                            end
                        else
                            if ~(isstruct(varargin{1}{id})==struct_data && isobject(varargin{1}{id})==obj_data && numel(varargin{1}{id})==1)
                                wout=[]; fitdata=[]; ok=false; mess='Check form of data to be fitted';
                                if nargout<3, error(mess), else return, end
                            end
                        end
                    end
                    % Now do fitting, handling simpler case of one dataset only separately
                    if numel(varargin{1})==1
                        [wout,fitdata,ok,mess]=multifit(varargin{1},varargin{2:end});
                        if ~ok && nargout<3, error(mess), end
                    else
                        wout=cell(size(varargin{1}));
                        fitdata=repmat(struct,size(wout));  % array of empty structures
                        ok=false(size(wout));
                        mess=cell(size(varargin{1}));
                        ok_fit_performed=false;
                        for id=1:numel(varargin{1})
                            [wout{id},fitdata_tmp,ok(id),mess{id}]=multifit(varargin{1}{id},varargin{2:end});
                            if ok(id)
                                if ~ok_fit_performed
                                    ok_fit_performed=true;
                                    fitdata=expand_as_empty_structure(fitdata_tmp,size(varargin{1}),id);
                                else
                                    fitdata(id)=fitdata_tmp;
                                end
                            else
                                disp(['ERROR (dataset ',num2str(id),'): ',mess{id}])
                            end
                        end
                    end
                elseif isstruct(varargin{1}) || isobject(varargin{1})
                    % Now do fitting, handling simpler case of one dataset only separately
                    if numel(varargin{1})==1
                        [wout,fitdata,ok,mess]=multifit(varargin{1},varargin{2:end});
                        if ~ok && nargout<3, error(mess), end
                    else
                        wout=varargin{1};
                        fitdata=repmat(struct,size(wout));  % array of empty structures
                        ok=false(size(wout));
                        mess=cell(size(varargin{1}));
                        ok_fit_performed=false;
                        for id=1:numel(varargin{1})
                            [wout_tmp,fitdata_tmp,ok(id),mess{id}]=multifit(varargin{1}(id),varargin{2:end});
                            if ok(id)
                                wout(id)=wout_tmp;
                                if ~ok_fit_performed
                                    ok_fit_performed=true;
                                    fitdata=expand_as_empty_structure(fitdata_tmp,size(varargin{1}),id);
                                else
                                    fitdata(id)=fitdata_tmp;
                                end
                            else
                                if nargout<3, error([mess{id}, ' (dataset ',num2str(id),')']), end
                                disp(['ERROR (dataset ',num2str(id),'): ',mess{id}])
                            end
                        end
                    end
                else
                    wout=[]; fitdata=[]; ok=false; mess='Check form of data to be fitted';
                    if nargout<3, error(mess), end
                end
            else
                wout=[]; fitdata=[]; ok=false; mess='Check input arguments - unexpected fit function location in argument list';
                if nargout<3, error(mess), end
            end
            return
        end
    end
    wout=[]; fitdata=[]; ok=false; mess='Check input arguments - no fit function found';
    if nargout<3, error(mess), end
else
    wout=[]; fitdata=[]; ok=false; mess='Check number of input arguments';
    if nargout<3, error(mess), end
end

%----------------------------------------------------------------------------------------------------------------------
function sout=expand_as_empty_structure(sin,sz,id)
% Expand a scalar structure as an empty structure, except retaining element id as the input
if isstruct(sin) && isscalar(sin)
    nams=fieldnames(sin);
    args=[nams';repmat({[]},1,numel(nams))];
    sout=repmat(struct(args{:}),sz);
    sout(id)=sin;
else
    error('Input not a scalar structure')
end
