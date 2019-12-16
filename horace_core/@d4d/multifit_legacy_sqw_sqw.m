function [wout, fitdata, ok, mess] = multifit_legacy_sqw_sqw(win, varargin)
% Simultaneously fits a model for S(Q,w) to an array of d4d objects, with
% optional background functions that are also models for S(Q,w).
%
% A background function can be added to the fit function.
% If passed an array of datasets, then each dataset is fitted independently.
%
%
% Fit several datasets in succession to a given function:
% -------------------------------------------------------
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (w, func, pin)
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (w, func, pin, pfree)
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background function added to the function:
% --------------------------------------------------------
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (..., bkdfunc, bpin)
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (..., bkdfunc, bpin, bpfree, bpbind)
%
%
% Additional keywords controlling the fit:
% ----------------------------------------
% You can alter the range of data to fit, alter convergence criteria,
% verbosity of output etc. with keywords, some of which need to be paired
% with input values, some of which are just logical flags:
%
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw (..., keyword, value, ...)
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
%     Control if foreground and background functions are global or local:
%   *   'global_foreground' Foreground function applies to all datasets
%                          [Default: true]
%   *   'local_foreground'  Foreground function(s) apply to each dataset
%                          independently [Default: false]
%   *   'local_background'  Background function(s) apply to each dataset
%                          independently [Default: true]
%   *   'global_background' Background function applies to all datasets
%                          [Default: false]
%
%   EXAMPLES:
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw(...,'keep',[0.4,1.8],'list',2)
%
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw(...,'select')
%
% If unable to fit, then the program will halt and display an error message.
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = multifit_legacy_sqw_sqw (...)
%
%
%------------------------------------------------------------------------------
% Description in full
%------------------------------------------------------------------------------
% Input:
% ======
%   w       d4d object or array of d4d objects to be fitted
%
%   func    A handle to the function to be fitted to each of the datasets.
%           The function must calculate S(Q,w), which will be evaluated at
%           the bin centres. It must have the form:
%               weight = my_sqwfunc (qh,qk,ql,en,p)
%
%             or, more generally:
%               weight = my_sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%
%             where
%               - qh,qk,ql,en Arrays containing the coordinates of a set of
%                            points in momentum-energy space
%               - p           A vector of numeric parameters that define the
%                            function e.g. [A,j1,j2,gam] as intensity, exchange
%                            constants, inverse lifetime
%               - c1,c2,...   Any further arguments needed by the function (e.g.
%                            they could be the filenames of lookup tables)
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
%           The function must calculate S(Q,w), which will be evaluated at
%           the bin centres. It must have the form:
%               weight = my_sqwfunc (qh,qk,ql,en,p)
%
%             or, more generally:
%               weight = my_sqwfunc (qh,qk,ql,en,p,c1,c2,..)
%
%             where
%               - qh,qk,ql,en Arrays containing the coordinates of a set of
%                            points in momentum-energy space
%               - p           A vector of numeric parameters that define the
%                            function e.g. [A,j1,j2,gam] as intensity, exchange
%                            constants, inverse lifetime
%               - c1,c2,...   Any further arguments needed by the function (e.g.
%                            they could be the filenames of lookup tables)
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
%           If fitting an array of datasets: then 'keep' applies to all
%           datasets.
%
%           Alternatively, give a cell array of arrays, one per data set
%           to specify different ranges to keep for each dataset.
%
%   'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. 'remove' takes precedence over 'keep'.
%
%   'mask'  Array of ones and zeros, with the same number of elements as the
%           input data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting (1=keep, 0=remove).
%
%           If fitting an array of datasets: then the mask array applies to
%           all datasets.
%
%           Alternatively, give a cell array of mask arrays, one per data set
%           to specify different masks for each dataset.
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
% Control if foreground and background functions are global or local:
% * 'global_foreground' Foreground function applies to all datasets
%                      [Default: true]
% * 'local_foreground'  Foreground function(s) apply to each dataset
%                      independently [Default: false]
% * 'local_background'  Background function(s) apply to each dataset
%                      independently [Default: true]
% * 'global_background' Background function applies to all datasets
%                      [Default: false]
%
%
%   Example:
%   >> [wout, fitdata] = multifit_legacy_sqw_sqw(...,'keep',[0.4,1.8],'list',2)
%
%
% Output:
% =======
%   wout    d4d object or array of d4d objects evaluated at the
%           final fit parameter values.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%           wout(i)==w(i)
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
% Fit spin wave model to a collection of four d1d objects, allowing only intensity
% and coupling constant to vary:
%   >> weight=100; SJ=10; gamma=3;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], [1,1,0])
% (Identical to using multifit_sqw because we are not fitting the background)
%
% Allow all spin wave parameters to vary, only keep data in
% restricted range, and allow a background of form (const + A|Q|^2):
%   >> weight=100; SJ=10; gamma=3;
%   >> const=0; quad=0;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma],...
%                       @const_modqsqr, [const,quad],'keep',[-1.5,0.5])
%
% As above, but allow the intensities to vary independently for the spin
% waves while keeping the exchange constant and lifetime global
%   >> weight=100; SJ=10; gamma=3;
%   >> const=0; quad=0;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma],...
%                       [],{[],{1,1,1},{1,1,1},{1,1,1}}
%                       @const_modqsqr, [const,quad],'keep',[-1.5,0.5],...
%                       'local_foreground')

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   sqw_doc = fullfile(fileparts(which('multifit_legacy_Horace')),'_docify');
%   first_line = {'% Simultaneously fits a model for S(Q,w) to an array of d4d objects, with',...
%                 '% optional background functions that are also models for S(Q,w).'}
%   main = false;
%   method = true;
%   synonymous = false;
%
%   multifit=true;
%   func_prefix='multifit_legacy';
%   func_suffix='_sqw_sqw';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%   obj_name = 'd4d'
%
%   doc_forefunc = fullfile(sqw_doc,'doc_fitfunc_dnd_sqw.m')
%   doc_backfunc = fullfile(sqw_doc,'doc_fitfunc_dnd_sqw.m')
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
% EXAMPLES:
% =========
%
% Fit spin wave model to a collection of four d1d objects, allowing only intensity
% and coupling constant to vary:
%   >> weight=100; SJ=10; gamma=3;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma], [1,1,0])
% (Identical to using multifit_sqw because we are not fitting the background)
%
% Allow all spin wave parameters to vary, only keep data in
% restricted range, and allow a background of form (const + A|Q|^2):
%   >> weight=100; SJ=10; gamma=3;
%   >> const=0; quad=0;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma],...
%                       @const_modqsqr, [const,quad],'keep',[-1.5,0.5])
%
% As above, but allow the intensities to vary independently for the spin
% waves while keeping the exchange constant and lifetime global
%   >> weight=100; SJ=10; gamma=3;
%   >> const=0; quad=0;
%   >> [wout, fdata] = multifit_sqw_sqw (w, @bcc_damped_spinwaves, [ht,SJ,gamma],...
%                       [],{[],{1,1,1},{1,1,1},{1,1,1}}
%                       @const_modqsqr, [const,quad],'keep',[-1.5,0.5],...
%                       'local_foreground')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargout<3
    [wout,fitdata]=multifit_sqw_sqw(sqw(win), varargin{:});  % forces failure if there is an error, as is the convention for fit when no ok argument
else
    [wout,fitdata,ok,mess]=multifit_sqw_sqw(sqw(win), varargin{:});
end
wout=dnd(wout);

