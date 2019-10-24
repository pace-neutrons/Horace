function [wout, fitdata, ok, mess, varargout] = tobyfit_legacy(win, varargin)
% Simultaneously fits a resolution broadened model for S(Q,w) to an array of sqw
% objects, with optional background functions.
%
% ********************************************************************************
%    DEPRECATED FUNCTION: tobyfit_legacy
%       Please replace this call to tobyfit_legacy with one to tobyfit which is
%       much more flexible. Note that the argument list is a bit different.
% ********************************************************************************
%
% Allows background functions (one per dataset) whose parameters
% vary independently for each dataset to be added to the fit function.
%
% Note: instead of a global foreground function, you can specify foreground
% functions (one per dataset) whose parameters vary independently for each
% dataset can be specified if the 'local_foreground' keyword is given.
% Similarly, you can specify a global background function, by given the
% keyword option 'global_background'
%
%
% Simultaneously fit datasets to a single function ('global foreground'):
% -----------------------------------------------------------------------
%   >> [wout, fitdata] = tobyfit (w, func, pin)
%   >> [wout, fitdata] = tobyfit (w, func, pin, pfree)
%   >> [wout, fitdata] = tobyfit (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background functions added to the foreground:
% -----------------------------------------------------------
%   >> [wout, fitdata] = tobyfit (..., bkdfunc, bpin)
%   >> [wout, fitdata] = tobyfit (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = tobyfit (..., bkdfunc, bpin, bpfree, bpbind)
%
%   If you give just one background function then that function will be used for
%   all datasets, but the parameters will be varied independently for each dataset
%
%
% Local foreground functions and/or a global background function
% --------------------------------------------------------------
% The default is for the foreground function to be global, and the
% background function(s) to be local. That is, the parameters of a single
% foreground function are varied to minimise chi-squared across all the
% datasets, and the background function parameters are varied independently
% for each dataset.
%
% To have independent foreground functions for each dataset:
%   >> [wout, fitdata] = tobyfit (..., 'local_foreground')
%
%   If you give just one foreground function then that function will be used for
%   all datasets, but the parameters will be varied independently for each dataset
%
% To have a global background function across all datasets:
%   >> [wout, fitdata] = tobyfit (..., 'global_background')
%
%
% Additional keywords controlling the fit:
% ----------------------------------------
% You can alter the range of data to fit, alter convergence criteria,
% verbosity of output etc. with keywords, some of which need to be paired
% with input values, some of which are just logical flags:
%
%   >> [wout, fitdata] = tobyfit (..., keyword, value, ...)
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
%     Special keyword(s):
%       'mc_contributions'  Define the contributing components to the
%                           resolution function.
%       'mc_npoints'        Sets the number of Monte Carlo samplings per
%                           pixel
%       'refine_crystal'    Options controlling refinement of crystal
%                           orientation and lattice parameters
%       'refine_moderator'  Options controlling refinement of moderator
%                           parameters
%
%   EXAMPLES:
%   >> [wout, fitdata] = tobyfit(...,'keep',[0.4,1.8],'list',2)
%
%   >> [wout, fitdata] = tobyfit(...,'select')
%
% If unable to fit, then the program will halt and display an error message.
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = tobyfit (...)
%
%
%------------------------------------------------------------------------------
% Description in full
%------------------------------------------------------------------------------
% Note on form of arguments if 'local_foreground' or 'local_background':
%
% If the parameters of the fit functions to the datasets are independent
% then the general rule is as follows:
% - Each input argument should be a cell array, with each element of the cell
%   array being the input argument for the function fitting the corresponding
%   data set;
% *OR*
% - If the input argument is not a cell array, it is taken as the input
%   for the function fitting each data set. That is, internally it is
%   converted to repmat({arg},size(w)), where arg is the argument and w is
%   the array of input data sets.
%
% Use this rule to avoid any confusion about how to provide the initial
% parameter values or binding of parameters, where the input for a single
% data set can itself be a cell array. For full details, see the corresponding
% entries for these arguments below.
%
%
% Input:
% ======
%   w       sqw object or array of sqw objects to be fitted
%
%   func    A handle to the function to be fitted to the datasets.
%           If 'local_forground' is set to true, then the same function will
%           be fitted independently to each dataset. Alternatively, give an
%           array of handles, one per dataset.
%           The function must calculate S(Q,w). It must have the form:
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
%
%           Case of global foreground function
%           ----------------------------------
%            - If the function takes just a numeric array of parameters, p,
%              then pin contains the initial values, that is, pin is the
%              array [p0(1), p0(2)...]
%
%            - If further parameters are needed by the function, then wrap
%              them as a cell array, that is, pin is the cell array
%               {[p0(1), p0(2)...], c1, c2, ...}
%
%           Case of local foreground functions:
%           -----------------------------------
%           If the function applies independently to each data set, that is,
%           'local_foreground' is set, then the same initial parameters will
%           be used for each of the functions. Alternatively, give a cell
%           array of initial values, one per data set.
%
%           EXAMPLES: Suppose there are two data sets:
%               pin=[area1,pos1,wid1];      % pin will be the input to the
%                                           % both fitting functions
%               pin={[area1,pos1,wid1],[area2,pos2,wid2]};
%                                           % Different starting values for
%                                           % the two data sets
%
%           If the parameters needed by the functions are cell arrays, take care:
%               pin={[area1,pos1,wid1],c1,c2}; % INVALID: cell array input
%                                           % is unpacked as the first element
%                                           % [area1,pos1,wid1] going to the
%                                           % first function, then c1 going
%                                           % to the second, and c2 not used
%                                           % This results in an error.
%               pin={{[area1,pos1,wid1],c1,c2}}; % Both functions are fed
%                                           % {[area2,pos2,wid2],c1,c2}
%               pin ={{[area1,pos1,wid1],c1_1,c2_1},[area2,pos2,wid2],c1_2,c2_2}}
%
%
%   pfree   [Optional] Indicates which are the free parameters in the fit.
%
%           Case of global foreground function
%           ----------------------------------
%           e.g. pfree=[1,0,1,0,0] indicates first and third parameters
%           are free, and the 2nd, 4th and 5th are fixed.
%           Default: if pfree is omitted or pfree=[] all parameters are free.
%
%
%           Case of local foreground functions
%           ----------------------------------
%           If the function applies independently to each dat set, that is,
%           'local_foreground' is set, then pfree applies equally to each
%           of the functions. Alternatively, give a cell array of logical
%           arrays e.g. if two functions, each with 5 parameters:
%               pfree = {[1,0,1,0,0],[1,0,0,1,1]}
%               pfree = {[1,0,1,0,0],[]}    % all parameter are free
%                                           % for the second data set
%
%
%   pbind   [Optional] Cell array that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin, (and also in bpin if there are
%           background functions).
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%
%           Case of global foreground function
%           ----------------------------------
%           A binding element describes how one parameter is bound to another:
%             pbind={1,3}               Parameter 1 is bound to parameter 3.
%
%           A binding description is made from a cell array of binding elements:
%             pbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio in a binding element, ignoring that
%           determined from pin:
%             pbind=(1,3,[],7.4)        Parameter 1 is bound to parameter 3
%                                      with ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. in this case
%                                      the foreground function rather than
%                                      the optional background function(s).
%             pbind={1,3,0,7.4}         Same meaning: 0 (or -1) for foreground
%                                      function
%
%           To bind to background function parameters (see below)
%             pbind={1,3,7}             Parameter 1 bound to parameter 3 of
%                                      the background function for the 7th
%                                      data set, in the ratio given by the
%                                      initial values.
%             pbind={1,3,7,3.14}        Give explicit binding ratio.
%             pbind={1,3,[2,3],3.14}    The binding is to parameter 3 of the
%                                      data set with index [2,3] in the array
%                                      of data sets (index must be a valid one
%                                      in the array size returned by size(w))
%
%           If the background function is defined as global i.e. you have set
%           'global_background' as true, then always refer to background with
%           index 1 because in this case there is only one background function.
%             pbind={1,3,1,3.14}
%
%           EXAMPLE:
%             pbind={{1,3,[],7.4},{4,3,0,0.023},{5,2,1},{6,3,2,3.14}}
%                                       Parameters 1 and 4 bound to parameter
%                                      3, and parameter 5 is bound to the 2nd
%                                      parameter of the background to the first
%                                      data set, and parameter 6 is bound to
%                                      parameter 3 of the background to the
%                                      second data set.
%
%           Note that you cannot bind a parameter to a parameter that is
%           itself bound to another parameter. You can bind to a fixed or free
%           parameter.
%
%           Case of local foreground functions
%           ----------------------------------
%           If the function applies independently to each data set, that is,
%           'local_foreground' is set, then pbind must be a cell array of
%           binding descriptions of the form above, for each data set. Each
%           of those binding descriptions is in turn a cell array.
%           E.g. if there are two datasets, a valid pbind is:
%            pbind={ {{1,3},{4,3},{5,6}}, {{1,3},{7,10}} }
%           where the element {{1,3},{4,3},{5,6}} is the binding description
%           for the first data set, and {{1,3},{7,10}} is for the second.
%
%           To reference parameters in the foreground function applying to
%           a particular data set, give the index of the dataset as a
%           negative number or array (c.f. a positive index to reference
%           the background function applying to a particular dataset)
%            pbind={1,3}               Parameter 1 is bound to parameter 3
%                                     of the same function
%
%            pbind={1,3,-4}            Parameter 1 is bound to parameter 3
%                                     of the function fitting the 4th data set
%
%            pbind={1,3,-[2,3]}        Parameter 1 is bound to parameter 3
%                                     of the function fitting data set w(2,3)
%
%           It is easy to get confused about how pbind applies to the
%           datasets, because to bind two parameters requires a cell array
%           (e.g. {1,3}), to bind several parameters requires a cell array
%           of cell arrays (e.g. {{1,3},{2,4,[],1.3}}), and lastly if there
%           are several data sets we will in general have a cell array of
%            *these* cell arrays. The rule is as follows:
%           - If pbind is scalar cell array (i.e. size(pbind)==[1,1]), then
%            pbind applies to every one of the data sets.
%           - If size(pbind)==size(w) i.e. the number of cell arrays inside
%            pbind matches the number of data sets, then each cell array of
%            pbind applies to one dataset.
%
%           EXAMPLE: Suppose we have three data sets
%             pbind={{1,3,[],7.4}, {4,3,[],0.023}}          INVALID
%                                       size(pbind)==[1,2] i.e. there are
%                                      two cell arrays in pbind, which is
%                                      inconsistent with the number of data sets
%
%             pbind={{{1,3,[],7.4}, {4,3,[],0.023}}}        OK
%                                       size(pbind)==[1,1] so the content:
%                                           {{1,3,[],7.4},{4,3,[],0.023}}
%                                       applies to every data set; which is
%                                       parameters 1 and 4 bound to parameter 3
%
%             pbind={{1,3,[],7.4}, {4,3,[],0.023}, {{2,6},{3,6}}}   OK
%                                       size(pbind)==[1,3] i.e. there are
%                                      three cell arrays in pbind, which
%                                      corresponds to one for each data set.
%                                      In this case parameter 1 is bound to
%                                      parameter 3 in the function fitting the
%                                      first data set, parameters 4 is bound
%                                      to parameter 3 in the function fitting
%                                      the second data set, and parameters 2
%                                      and 3 are bound to parameter 6 in the
%                                      function fitting the third data set.
%
%   Optional background function:
%   -----------------------------
%   bkdfunc A handle to the background function that will be independently
%           fitted to the datasets, or an array of function handles, one
%           per dataset.
%           If 'global_background' is set to true, then give just one
%           function handle; that function will be fitted globaly to all
%           data sets.
%           The function will be evaluated at the bin centres. It must have
%           the form:
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
%   bpin    Initial parameter values for the background functions:
%           See the description of the foreground function for details for
%           both global and local fitting functions.
%           Remember that the default is for local background functions.
%
%   bpfree  Array indicating which parameters are free. See the
%           description of the foreground function for details for
%           both global and local fitting functions.
%           Remember that the default is for local background functions.
%
%   bpbind  [Optional] Indicates which parameters are bound to other
%           parameters in a fixed ratio determined by the initial
%           parameter values contained in pin and bpin.
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%
%           The syntax is the same as for the foreground function. Rather than
%           repeat the documentation for pbind with minor changes to refer to
%           background functions, the general form of both pbind and bpbind is
%           described here.
%
%           - A binding description for a fit function is a cell array of
%             binding elements of the form:
%               {1,3}                   Parameter 1 is bound to parameter 3
%                                      of the same function, in the ratio
%                                      determined by the initial values.
%               {1,3,[],7.4}            Parameter 1 is bound to parameter 3,
%                                      of the same function, with ratio 7.4
%               {1,3,ind,7.4}            Parameter 1 is bound to parameter 3
%                                      of a different function, determined by
%                                      the value of ind, with ratio 7.4
%                where  ind = []        Binding parameters within he same
%                                      function
%
%                or, in the case of foreground function(s):
%                       ind = -1        The foreground function for the first
%                                      data set (or the global foreground
%                                      function, if 'global_foreground' is true)
%                       ind = -3        The foreground function for the third
%                                      data set (an index other than -1 is
%                                      only valid if 'local_foreground')
%                       ind = -[2,3]    The foreground function for data set
%                                      with index [2,3] in the input data w
%
%                or, in the case of background function(s):
%                       ind =  1        The background function for the first
%                                      data set (or the global foreground
%                                      function, if 'global_background' is true)
%                       ind =  3        The background function for the third
%                                      data set (an index other than 1 is
%                                      only valid if 'local_background')
%                       ind= [2,3]      The foreground function for data set
%                                      with index [2,3] in the input data w
%
%           - If the fit function is global, you can only give a single
%             binding description
%
%           - If the fit functions are local, then give a cell array of
%             binding descriptions
%               - if there is only one binding description in the cell array
%                 then it will apply to all fit functions
%               - if the number of binding descriptions equlas the number of
%                 data sets, then there is one binding description per fit
%                 function
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
% Special keyword(s):
%   'mc_contributions'  Define the contributing components to the resolution
%                       function. This is a structure with fields set to
%                       true or false accordingly. To generate the
%                       structure use the function tobyfit_mc_contributions.
%                       Type >> help tobyfit_mc_contributions for details
%                       Default: all components contribute
%
%   'mc_npoints'        Sets the number of Monte Carlo samplings per pixel.
%                       e.g. (...,'mc_npoints',100,...)
%                       Default: 10 (usually good for a first estimate)
%
%   'refine_crystal'    Options controlling refinement of crystal orientation
%                       and lattice parameters. This is a structure, which can be
%                       generated by the function tobyfit_refine_crystal_options.
%                       Type >> help tobyfit_refine_crystal_options for details.
%                       Default: No refinement
%
%   'refine_moderator'  Options controlling refinement of moderator parameters.
%                       This is a structure, which can be generated by the
%                       function tobyfit_refine_moderator_options. Type
%                       >> help tobyfit_refine_moderator_options for
%                       details.
%                       Default: No refinement
%
%
%   Example:
%   >> [wout, fitdata] = tobyfit(...,'keep',[0.4,1.8],'list',2)
%
%
% Output:
% =======
%   wout    sqw object or array of sqw objects evaluated at the
%           final fit parameter values.
%
%           If there was a problem i.e. ok==false, then wout=[].
%
%   fitdata Structure with result of the fit for each dataset. The fields are:
%           p      - Best fit foreground function parameter values
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           sig    - Estimated errors of foreground parameters (=0 for fixed
%                    parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bp     - Background parameter values
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bsig   - Estimated errors of background (=0 for fixed parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           corr   - Correlation matrix for free parameters
%           chisq  - Reduced Chi^2 of fit i.e. divided by:
%                       (no. of data points) - (no. free parameters))
%           converged - True if the fit converged, false otherwise
%           pnames - Foreground parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%           bpnames- Background parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%
%           If there was a problem i.e. ok==false, then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%                 both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g. the
%                 number of free parameters equals or exceeds the number
%                 of data points
%
%   mess    Error message if ok==false; Empty string if ok==true.

persistent first_time_call

if isempty(first_time_call)
    disp('% ********************************************************************************')
    disp('%    DEPRECATED FUNCTION: tobyfit_legacy')
    disp('%       Please replace this call to tobyfit_legacy with one to tobyfit which is')
    disp('%       much more flexible. Note that the argument list is a bit different.')
    disp('% ********************************************************************************')
end

%-------------------------------------------------------------------------------
% <#doc_def:>
%   multifit_doc = fullfile(fileparts(which('multifit_gateway_main')),'_docify');
%   sqw_doc = fullfile(fileparts(which('multifit_legacy_Horace')),'_docify');
%   first_line = {'% Simultaneously fits a resolution broadened model for S(Q,w) to an array of sqw'...
%                 '% objects, with optional background functions.'}
%   main = false;
%   method = true;
%   synonymous = false;
%
%   multifit=true;
%   func_prefix='tobyfit';
%   func_suffix='';
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit')
%   obj_name = 'sqw'
%
%   doc_forefunc = fullfile(sqw_doc,'doc_fitfunc_sqw_sqw.m')
%   doc_backfunc = fullfile(sqw_doc,'doc_fitfunc_sqw_simple.m')
%
%   custom_keywords = true;
%   doc_custom_keywords_short = fullfile(sqw_doc,'doc_tobyfit_keywords_short.m');
%   doc_custom_keywords_long  = fullfile(sqw_doc,'doc_tobyfit_keywords_long.m');
%
% <#doc_beg:>  multifit_legacy
%   <#file:> fullfile('<multifit_doc>','doc_multifit_short.m')
%
%
%   <#file:> fullfile('<multifit_doc>','doc_multifit_long.m')
% <#doc_end:>
%-------------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% Clean up any persistent or global storage in case Tobyfit was left in a strange state
% -------------------------------------------------------------------------------------
tobyfit_cleanup     % Initialise Tobyfit
if matlab_version_num>=7.06     % R2008a or more recent: robust cleanup even if cntl-c
    cleanupObj=onCleanup(@tobyfit_cleanup);
end


% Parse input arguments
% ---------------------
% Default output arguments if error
wout=[];
fitdata=[];
rlu_corr=[];
fitmod=[];

% Check the data types are ok
for i=1:numel(win)
    if ~is_sqw_type(win(i));   % must be if sqw type
        ok=false; mess='All input datasets must be sqw type';
        if nargout<3, error(mess), else return, end
    end
end

% Strip out Tobyfit specific arguments from varargin
arglist = struct('mc_contributions',[],'mc_npoints',10,'refine_crystal',[],'refine_moderator',[]);
[varargin,opt,present] = parse_arguments(varargin,arglist,[],struct('keys_at_end',false));
mc_contrib=opt.mc_contributions;
mc_npoints=opt.mc_npoints;
if present.refine_crystal
    refine_crystal=true;
    xtal_opts=opt.refine_crystal;
else
    refine_crystal=false;
end
if present.refine_moderator
    refine_moderator=true;
    mod_opts=opt.refine_moderator;
else
    refine_moderator=false;
end
if refine_crystal && refine_moderator
    ok=false; mess='Cannot refine both crystal parameters and moderator parameters - choose only one of these options';
    if nargout<3, error(mess), else return, end
end

% Parse the input arguments to multifit
[ok,mess,pos,func,plist,pfree,pbind,bpos,bfunc,bplist,bpfree,bpbind,narg] = multifit_gateway_parsefunc (win, varargin{:});
if ~ok
    if nargout<3, error(mess), else return, end
end
ndata=1;     % There is just one argument before the varargin
pos=pos-ndata;
bpos=bpos-ndata;
narg=narg-ndata;


% Prepare Monte Carlo arguments, crystal and moderator refinement
% ---------------------------------------------------------------
% Set which contributions to the resolution are to be accounted for
[mc_contrib,ok,mess]=tobyfit_mc_contributions(mc_contrib);
if ~ok
    if nargout<3, error(mess), else return, end
end

% Check the number of Monte Carlo points
if ~isnumeric(mc_npoints) || ~isscalar(mc_npoints) || mc_npoints-round(mc_npoints)~=0 || mc_npoints<1
    ok=false; mess='Number of Monte Carlo points per pixel must be an integer greater or equal to one';
    if nargout<3, error(mess), else return, end
end

% Check crystal refinement input, if refinement is requested
if refine_crystal
    % Check lattice parameters in input objects
    [alatt0,angdeg0,ok,mess] = lattice_parameters(win);
    if ~ok
        mess=['Crystal refinement: ',mess];
        if nargout<3, error(mess), else return, end
    end

    % Check validity of refinement options structure, and set starting values for lattice parameters if necessary
    [xtal_opts,ok,mess] = tobyfit_refine_crystal_options(xtal_opts);
    if ~ok
        if nargout<3, error(mess), else return, end
    end
    if isempty(xtal_opts.alatt)
        xtal_opts.alatt=alatt0;
    end
    if isempty(xtal_opts.angdeg)
        xtal_opts.angdeg=angdeg0;
    end

    % Append crystal refinement parameters to the foreground parameter arguments
    [plist,pfree,pbind]=refine_crystal_pack_parameters (plist,pfree,pbind,xtal_opts);

    % Re-create argument list for multifit
    pbind=multifit_gateway_pbind_struct_to_cell(pbind);     % return to cell array input
    if isempty(bpos)    % no background function(s) present
        varargin=[{func,plist,pfree,pbind},varargin(narg+1:end)];
    else
        bpbind=multifit_gateway_pbind_struct_to_cell(bpbind);
        varargin=[{func,plist,pfree,pbind,bfunc,bplist,bpfree,bpbind},varargin(narg+1:end)];
        bpos=5;
    end

    % Fill refine argument to be passed as argument to multifit
    xtal.refine=true;
    xtal.urot=xtal_opts.urot;
    xtal.vrot=xtal_opts.vrot;
    xtal.ub0 = ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt0,angdeg0));   % ub matrix for lattice parameters in sqw objects

else
    xtal.refine=false;
end

% Check moderator refinement input, if refinement is requested
if refine_moderator
    % Check that the moderator contribution is included to the resolution calculation
    if ~mc_contrib.moderator
        mess='Moderator refinement: must have Monte Carlo contribution from moderator selected in ''mc_contributions''';
        if nargout<3, error(mess), else return, end
    end
    % Check all incident energies are the same in input objects
    [ei_common,emode,ok,mess] = get_efix(win);
    if ~ok
        mess=['Moderator refinement: ',mess];
        if nargout<3, error(mess), else return, end
    end

    % Check validity of refinement options structure on entry
    [mod_opts,ok,mess] = tobyfit_refine_moderator_options(mod_opts);
    if ~ok
        if nargout<3, error(mess), else return, end
    end

    % Get model and starting parameters if not given
    if isempty(mod_opts.pulse_model) || isempty(mod_opts.pp_init)
        [pulse_model_default,pp_init_default,ok,mess] = get_mod_pulse(win);
        if ~ok
            if nargout<3, error(mess), else return, end
        end
        if isempty(mod_opts.pulse_model)
            mod_opts.pulse_model=pulse_model_default;
        end
        if isempty(mod_opts.pp_init)
            mod_opts.pp_init=pp_init_default(:)';   % guarantee it is a row vector
        end
    end
    if isempty(mod_opts.pp_free)
        mod_opts.pp_free=true(size(mod_opts.pp_init));  % default is all parameters are free
    end

    % Check validity of refinement options structure after filling missing arguments
    [mod_opts,ok,mess] = tobyfit_refine_moderator_options(mod_opts);
    if ~ok
        if nargout<3, error(mess), else return, end
    end

    % Append crystal refinement parameters to the foreground parameter arguments
    [plist,pfree,pbind]=refine_moderator_pack_parameters (plist,pfree,pbind,mod_opts);

    % Re-create argument list for multifit
    pbind=multifit_gateway_pbind_struct_to_cell(pbind);     % return to cell array input
    if isempty(bpos)    % no background function(s) present
        varargin=[{func,plist,pfree,pbind},varargin(narg+1:end)];
    else
        bpbind=multifit_gateway_pbind_struct_to_cell(bpbind);
        varargin=[{func,plist,pfree,pbind,bfunc,bplist,bpfree,bpbind},varargin(narg+1:end)];
        bpos=5;
    end

    % Fill refine argument to be passed as argument to multifit
    modshape.refine=true;
    modshape.pulse_model=mod_opts.pulse_model;
    modshape.pp=mod_opts.pp_init;
    modshape.ei=ei_common;

else
    modshape.refine=false;
end


% Perform the fit
% ---------------
% Set control options for function evaluation
resol_conv_tobyfit_mc_control('multifit',size(win))


% Wrap the foreground and background functions
wrap_plist={mc_contrib,mc_npoints,xtal,modshape};
args=multifit_gateway_wrap_functions (varargin,pos,func,plist,bpos,bfunc,bplist,...
                                        @resol_conv_tobyfit_mc,wrap_plist,@func_eval,{});

% Least-squares fitting
[ok,mess,wout,fitdata] = multifit_gateway_main (win, args{:}, 'init_func', @resol_conv_tobyfit_mc_init);
if ~ok
    if nargout<3, error(mess), else return, end
end


% Pack output arguments
% ---------------------
% Get the rlu correction matrix if crystal refinement
if refine_crystal
    if numel(func)==1
        pxtal=fitdata.p(end-8:end);
    else
        pxtal=fitdata.p{1}(end-8:end);
    end
    alatt=pxtal(1:3);
    angdeg=pxtal(4:6);
    rotvec=pxtal(7:9);
    rotmat=rotvec_to_rotmat2(rotvec);
    ub=ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt,angdeg));
    rlu_corr=ub\rotmat*xtal.ub0;
    % Pack output arguments
    varargout={rlu_corr};
end

% Get the moderator refinement parameters
if refine_moderator
    fitmod.pulse_model=modshape.pulse_model;
    npmod=numel(modshape.pp);
    if numel(func)==1
        fitmod.p=fitdata.p(end-npmod+1:end);
        fitmod.sig=fitdata.sig(end-npmod+1:end);
    else
        fitmod.sig=fitdata.sig{1}(end-npmod+1:end);
    end
    % Pack output arguments
    varargout={fitmod.pulse_model,fitmod.p,fitmod.sig};
end


% Cleanup resolution convolution status
% -------------------------------------
if matlab_version_num<7.06     % prior to R2008a: does not automatically call cleanup (see start of this function)
    tobyfit_cleanup
end

%=================================================================================================================
function tobyfit_cleanup
% Cleanup Tobyfit
resol_conv_tobyfit_mc_control
refine_moderator_sampling_table_buffer
