function [ok,mess,parsing,output] = multifit_main(varargin) 
%-------------------------------------------------------------------------- 
% The documentation for multifit is reproduced below, but this gateway 
% function differs as follows: 
% 
% - The output arguments are different, although the input arguments are 
%   the same; 
% - There are additional keyword arguments which, although visible from the 
%   public multifits, are not advertised because they are meant only for 
%   developers. 
% 
% In full: 
% 
%   >> [ok,mess,parsing,output] = multifit_main(x,y,e,...) 
%   >> [ok,mess,parsing,output] = multifit_main(w,...) 
% 
% 
% Input: 
% ====== 
% Input arguments are exactly the same as for the public multifit 
% application. 
% 
% 
% Optional keywords: 
% ------------------ 
% Keywords that are logical flags are indicated by * 
% 
% * 'parsefunc_'  If present, parse the fit functions, parameter values 
%                 fixed/free and binding, but do not actually fit. This has 
%                 a use, for example, when repackaging the input for a 
%                 custom call to multifit. 
%                 Default: true 
% 
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
%   ok      True: A fit coould be performed. This includes the cases of 
%             both convergence and failure to converge 
%           False: Fundamental problem with the input arguments e.g. 
%             the number of free parameters equals or exceeds the number 
%             of data points 
% 
%   mess    Error message if ok==false; Empty string if ok==true. 
% 
%   parsing True if just checking parsing i.e. the keyword 'parsefunc_' was 
%           set to true; false if fitting or evaluating 
% 
%   output  Cell array of output; one of the two instances below if ok; 
%           empty cell array (1x0) if not ok. 
% 
% 
%  If 'parsefunc_' is false: 
%  ------------------------- 
% Contains two elements giving results of a fit or simulation: 
%	output = {wout, fitdata} 
% 
% See the corresponding output arguments in the multifit documentation below 
% for the form of wout and fitdata 
% 
% 
%  If 'parsefunc_' is true: 
%  ------------------------ 
% Contains details of parsing of input data and functions: 
%   output = {pos, func, plist, pfree, pbind,... 
%                       bpos, bfunc, bplist, bpfree, bpbind, narg}; 
% where: 
% 
%   ok          True if all ok, false if there is a syntax problem. 
%   mess        Character string containing error message if ~ok; '' if ok 
%   pos         Position of foreground function handle argument in input 
%              argument list 
%   func        Cell array of function handle(s) to foreground function(s) 
%   plist       Cell array of parameter lists, one per foreground function 
%   pfree       Cell array of logical row vectors, one per foreground function, 
%              describing which parameters are free or not 
%   pbind       Structure defining the foreground function binding, each field 
%              a cell array with the same size as the corresponding functions 
%              array: 
%           ipbound     Cell array of column vectors of indicies of bound 
%                      parameters, one vector per function 
%           ipboundto   Cell array of column vectors of the parameters to 
%                      which those parameters are bound, one vector per 
%                      function 
%           ifuncboundto  Cell array of column vectors of single indicies 
%                      of the functions corresponding to the free parameters, 
%                      one vector per function. The index is ifuncfree(i)<0 
%                      for foreground functions, and >0 for background functions. 
%           pratio      Cell array of column vectors of the ratios 
%                      (bound_parameter/free_parameter),if the ratio was 
%                      explicitly given. Will contain NaN if not (the ratio 
%                      will be determined from the initial parameter values). 
%                      One vector per function. 
%   bpos        Position of background function handle argument in input 
%              argument list 
%   bfunc       Cell array of function handle(s) to background function(s) 
%   bplist      Cell array of parameter lists, one per background function 
%   bpfree      Cell array of logical row vectors, one per background function, 
%              describing which parameters are free or not 
%   bpbind      Structure defining the background function binding, with the 
%              same format as the foreground binding structure above. 
%   narg        Total number of arguments excluding keyword-value options 
% 
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
% The documentation for multifit is reproduced below, but this gateway 
% function differs as follows: 
% 
% - The output arguments are different, although the input arguments are 
%   the same; 
% - There are additional keyword arguments which, although visible from the 
%   public multifits, are not advertised because they are meant only for 
%   developers. 
% 
% In full: 
% 
%   >> [ok,mess,parsing,output] = multifit_main(x,y,e,...) 
%   >> [ok,mess,parsing,output] = multifit_main(w,...) 
% 
% 
% Input: 
% ====== 
% Input arguments are exactly the same as for the public multifit 
% application. 
% 
% 
% Optional keywords: 
% ------------------ 
% Keywords that are logical flags are indicated by * 
% 
% * 'parsefunc_'  If present, parse the fit functions, parameter values 
%                 fixed/free and binding, but do not actually fit. This has 
%                 a use, for example, when repackaging the input for a 
%                 custom call to multifit. 
%                 Default: true 
% 
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
%   ok      True: A fit coould be performed. This includes the cases of 
%             both convergence and failure to converge 
%           False: Fundamental problem with the input arguments e.g. 
%             the number of free parameters equals or exceeds the number 
%             of data points 
% 
%   mess    Error message if ok==false; Empty string if ok==true. 
% 
%   parsing True if just checking parsing i.e. the keyword 'parsefunc_' was 
%           set to true; false if fitting or evaluating 
% 
%   output  Cell array of output; one of the two instances below if ok; 
%           empty cell array (1x0) if not ok. 
% 
% 
%  If 'parsefunc_' is false: 
%  ------------------------- 
% Contains two elements giving results of a fit or simulation: 
%	output = {wout, fitdata} 
% 
% See the corresponding output arguments in the multifit documentation below 
% for the form of wout and fitdata 
% 
% 
%  If 'parsefunc_' is true: 
%  ------------------------ 
% Contains details of parsing of input data and functions: 
%   output = {pos, func, plist, pfree, pbind,... 
%                       bpos, bfunc, bplist, bpfree, bpbind, narg}; 
% where: 
% 
%   ok          True if all ok, false if there is a syntax problem. 
%   mess        Character string containing error message if ~ok; '' if ok 
%   pos         Position of foreground function handle argument in input 
%              argument list 
%   func        Cell array of function handle(s) to foreground function(s) 
%   plist       Cell array of parameter lists, one per foreground function 
%   pfree       Cell array of logical row vectors, one per foreground function, 
%              describing which parameters are free or not 
%   pbind       Structure defining the foreground function binding, each field 
%              a cell array with the same size as the corresponding functions 
%              array: 
%           ipbound     Cell array of column vectors of indicies of bound 
%                      parameters, one vector per function 
%           ipboundto   Cell array of column vectors of the parameters to 
%                      which those parameters are bound, one vector per 
%                      function 
%           ifuncboundto  Cell array of column vectors of single indicies 
%                      of the functions corresponding to the free parameters, 
%                      one vector per function. The index is ifuncfree(i)<0 
%                      for foreground functions, and >0 for background functions. 
%           pratio      Cell array of column vectors of the ratios 
%                      (bound_parameter/free_parameter),if the ratio was 
%                      explicitly given. Will contain NaN if not (the ratio 
%                      will be determined from the initial parameter values). 
%                      One vector per function. 
%   bpos        Position of background function handle argument in input 
%              argument list 
%   bfunc       Cell array of function handle(s) to background function(s) 
%   bplist      Cell array of parameter lists, one per background function 
%   bpfree      Cell array of logical row vectors, one per background function, 
%              describing which parameters are free or not 
%   bpbind      Structure defining the background function binding, with the 
%              same format as the foreground binding structure above. 
%   narg        Total number of arguments excluding keyword-value options 
% 
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
% $Revision: 436 $ ($Date: 2015-07-06 09:58:15 +0100 (Mon, 06 Jul 2015) $) 
 
 
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
