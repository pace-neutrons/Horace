function [ok,mess,varargout] = multifit_gateway_main (varargin) 
%-------------------------------------------------------------------------- 
% The documentation for the public multifit application is reproduced below. 
% This is the gateway to the master multifit function, and its arguments 
% differs as follows: 
% 
% - The output arguments are in a different order, although the input 
%   arguments are the same; 
% - There is an additional keyword argument which although visible from the 
%   public multifit is not advertised because it is meant only for 
%   developers. 
% 
% In full: 
% 
%   >> [ok,mess,wout,fitdata] = multifit_main(x,y,e,...) 
%   >> [ok,mess,wour,fitdata] = multifit_main(w,...) 
% 
% 
% Input: 
% ====== 
% Input arguments are exactly the same as for the public multifit 
% application. 
% 
% 
% Optional keyword: 
% ----------------- 
%   'init_func'   Function handle: if not empty then apply a pre-processing 
%                function to the data before least squares fitting. 
%                 The purpose of this function is to allow pre-computation 
%                of quantities that speed up the evaluation of the fitting 
%                function. It must have the form: 
% 
%                   [ok,mess,c1,c2,...] = my_init_func(w)   % create c1,c2,... 
%                   [ok,mess,c1,c2,...] = my_init_func()    % recover stored 
%                                                           % c1,c2,... 
% 
%                where 
%                   w       Cell array, where each element is either 
%                           - an x-y-e triple with w(i).x a cell array of 
%                             arrays, one for each x-coordinate 
%                           - a scalar object 
% 
%                   ok      True if the pre-processed output c1, c2... was 
%                          computed correctly; false otherwise 
% 
%                   mess    Error message if ok==false; empty string 
%                          otherwise 
% 
%                   c1,c2,..Output e.g. lookup tables that can be 
%                          pre-computed from the data w 
% 
% 
% Output: 
% ======= 
% Output arguments are the same as the public multifit application, but the 
% order is changed from [wout,fitdata,ok,mess] ot [ok,mess,wout,fitdata] 
%-------------------------------------------------------------------------- 
% 
% Simultaneously fits a function to several datasets, with optional 
% background functions. 
% 
% The data to be fitted can be a set or sets of of x,y,e arrays, or an 
% object or array of objects of a class. [Note: if you have written your own 
% class, there are some required methods for this fit function to work. 
% See notes at the end of this help] 
% 
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
% Differs from fit, which independently fits each dataset in 
% succession. 
% 
% Simultaneously fit datasets to a single function ('global foreground'): 
% ----------------------------------------------------------------------- 
%   >> [wout, fitdata] = multifit (x, y, e, func, pin) 
%   >> [wout, fitdata] = multifit (x, y, e, func, pin, pfree) 
%   >> [wout, fitdata] = multifit (x, y, e, func, pin, pfree, pbind) 
% 
%   >> [wout, fitdata] = multifit (w, func, pin) 
%   >> [wout, fitdata] = multifit (w, func, pin, pfree) 
%   >> [wout, fitdata] = multifit (w, func, pin, pfree, pbind) 
% 
% These cover the respective cases of: 
%   - All parameters free 
%   - Selected parameters free to fit 
%   - Binding of various parameters in fixed ratios 
% 
% 
% With optional background functions added to the foreground: 
% ----------------------------------------------------------- 
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin) 
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin, bpfree) 
%   >> [wout, fitdata] = multifit (..., bkdfunc, bpin, bpfree, bpbind) 
% 
%   If you give just one background function then that function will be used for 
%   all datasets, but the parameters will be varied independently for each dataset 
% 
% 
% Local foreground functions and/or a global background function 
% -------------------------------------------------------------- 
% The default is for the foreground function to be global, and the 
% background function(s) to be local. That is, the parameters of a single 
% foreground function are varied to minimise chi-squared acroos all the 
% datasets, and the background function parameters are varied independently 
% for each dataset. 
% 
% To have independent foreground functions for each dataset: 
%   >> [wout, fitdata] = multifit (..., 'local_foreground') 
% 
%   If you give just one foreground function then that function will be used for 
%   all datasets, but the parameters will be varied independently for each dataset 
% 
% To have a global background function across all datasets: 
%   >> [wout, fitdata] = multifit (..., 'global_background') 
% 
% 
% Additional keywords controlling the fit: 
% ---------------------------------------- 
% You can alter the range of data to fit, alter convergence criteria, 
% verbosity of output etc. with keywords, some of which need to be paired 
% with input values, some of which are just logical flags: 
% 
%   >> [wout, fitdata] = multifit (..., keyword, value, ...) 
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
%       'fit'           Alter convergence critera for the fit etc. 
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
%   >> [wout, fitdata] = multifit(...,'keep',[0.4,1.8],'list',2) 
% 
%   >> [wout, fitdata] = multifit(...,'select') 
% 
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit without throwing an error, call with additional 
% arguments that return status and error message: 
% 
%   >> [wout, fitdata, ok, mess] = multifit (...) 
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
% data set can itself be a cell array. For full details, see the correponding 
% entries for these arguments below. 
% 
% 
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
%   func    A handle to the function to be fitted to the datasets. 
%           If 'local_forground' is set to true, then the same function will 
%           be fitted independently to each dataset. Alternatively, give an 
%           array of handles, one per dataset. 
%           If fitting x,y,e data, or a structure with fields w.x,w.y,w.e, 
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
%           If fitting objects, then if w is an instance of an object, the 
%           function(s) or method(s) must have the form: 
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
%           If fitting x,y,e data, or a structure with fields w.x,w.y,w.e, 
%           then the function(s) must have the form: 
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
%           If fitting objects, then if w is an instance of an object, the 
%           function(s) or method(s) must have the form: 
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
% 
%   Example: 
%   >> [wout, fitdata] = multifit(...,'keep',[0.4,1.8],'list',2) 
% 
% 
% Output: 
% ======= 
%   wout    Output with same form as input data but with y values evaluated 
%           at the final fit parameter values. If the input was three separate 
%           x,y,e arrays, then only the calculated y values are returned. 
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
% 
% 
% EXAMPLES: 
% ========= 
% 
% Fit a Gaussian on a linear background to two data sets: 
% 
% If the data is in arrays x,y,e arrays, then package data into an array of 
% structures with fields x,y,e: 
%   >> w=struct('x',x1,'y',y1,'e',e1);      % x1,y1,e1 contain first data set 
%   >> w(2)=struct('x',x2,'y',y2,'e',e2);   % x2,y2,e2 contain 2nd data set 
% 
% Fit a global Gaussian, with independent linear backgrounds which have the 
% same starting parameters: 
% 
%   >> pin=[20,10,3];   % Initial height, position and standard deviation 
%   >> bg=[2,0]         % Initial intercept and gradient of background 
%   >> [wfit,fitpar]=multifit(w,@gauss,pin,@linear_bg,bg) 
% 
% Remove a portion of the data, and give copious output during the fitting 
% - remove a common range: 
%   >> [wfit,fitpar]=multifit(w,@gauss,pin,@linear_bg,bg,'remove',... 
%                                             [12,14],'list',2) 
% - remove different ranges for the two data sets: 
%   >> [wfit,fitpar]=multifit(w,@gauss,pin,@linear_bg,bg,'remove',... 
%                                             {[12,14],[10,13]},'list',2) 
% 
% Fix the position and constrain (1) the constant part of the background 
% of the first data set to be a fixed multiple of the width of the Gaussian, 
% and (2) the gradient of the background to the second data set to be 
% a fixed multiple of the height of the Gaussian: 
% 
%   >> [wfit,fitpar]=multifit(w,@gauss,pin,[1,0,1],@linear_bg,bg,... 
%                             {{1,3,-1},{2,1,-1,1e-3}}) 
% 
% Fit independent Gaussians but which are constrained to have the same 
% widths 
% 
%   >> [wfit,fitpar]=multifit(w,@gauss,pin,{{},{3,3,1}},@linear_bg,bg,... 
%                                         'local_foreground') 
 
% <#doc_def:> 
%   first_line = {'% Simultaneously fits a function to several datasets, with optional',... 
%                 '% background functions.'} 
%   main = true; 
%   method = false; 
%   synonymous = false; 
% 
%   multifit=true; 
%   func_prefix='multifit'; 
%   func_suffix=''; 
%   differs_from = strcmpi(func_prefix,'multifit') || strcmpi(func_prefix,'fit') 
% 
%   custom_keywords = false; 
% 
% <#doc_beg:> 
%-------------------------------------------------------------------------- 
% The documentation for the public multifit application is reproduced below. 
% This is the gateway to the master multifit function, and its arguments 
% differs as follows: 
% 
% - The output arguments are in a different order, although the input 
%   arguments are the same; 
% - There is an additional keyword argument which although visible from the 
%   public multifit is not advertised because it is meant only for 
%   developers. 
% 
% In full: 
% 
%   >> [ok,mess,wout,fitdata] = multifit_main(x,y,e,...) 
%   >> [ok,mess,wour,fitdata] = multifit_main(w,...) 
% 
% 
% Input: 
% ====== 
% Input arguments are exactly the same as for the public multifit 
% application. 
% 
% 
% Optional keyword: 
% ----------------- 
%   'init_func'   Function handle: if not empty then apply a pre-processing 
%                function to the data before least squares fitting. 
%                 The purpose of this function is to allow pre-computation 
%                of quantities that speed up the evaluation of the fitting 
%                function. It must have the form: 
% 
%                   [ok,mess,c1,c2,...] = my_init_func(w)   % create c1,c2,... 
%                   [ok,mess,c1,c2,...] = my_init_func()    % recover stored 
%                                                           % c1,c2,... 
% 
%                where 
%                   w       Cell array, where each element is either 
%                           - an x-y-e triple with w(i).x a cell array of 
%                             arrays, one for each x-coordinate 
%                           - a scalar object 
% 
%                   ok      True if the pre-processed output c1, c2... was 
%                          computed correctly; false otherwise 
% 
%                   mess    Error message if ok==false; empty string 
%                          otherwise 
% 
%                   c1,c2,..Output e.g. lookup tables that can be 
%                          pre-computed from the data w 
% 
% 
% Output: 
% ======= 
% Output arguments are the same as the public multifit application, but the 
% order is changed from [wout,fitdata,ok,mess] ot [ok,mess,wout,fitdata] 
%-------------------------------------------------------------------------- 
% 
%   <#file:> multifit_doc:::doc_multifit_short.m 
% 
% 
%   <#file:> multifit_doc:::doc_multifit_long.m 
% 
% 
%   <#file:> multifit_doc:::doc_multifit_examples_1d.m 
% <#doc_end:> 
 
 
% Original author: T.G.Perring 
% 
% $Revision$ ($Date$) 
 
 
[ok,mess,parsing,output]=multifit_main(varargin{:},'noparsefunc_'); 
nout=nargout-2; 
varargout(1:nout)=output(1:nout);   % appears to work even if nout<=0 
