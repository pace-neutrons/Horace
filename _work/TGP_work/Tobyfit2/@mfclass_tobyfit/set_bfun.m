function obj = set_bfun(obj,varargin)
% Set background function or functions
%
% Set all background functions
%   >> obj = obj.set_bfun (functions, pin)
%   >> obj = obj.set_bfun (functions, pin, free)
%   >> obj = obj.set_bfun (functions, pin, free, bind)
%   >> obj = obj.set_bfun (functions, pin, 'free', free, 'bind', bind)
%
% Set a particular background function or set of background functions:
%   >> obj = obj.set_bfun (ifun, functions, pin,...)    % ifun is scalar or row vector
%
% Input:
% ------
%   functions   Function handle or cell array of function handles
%               e.g.  functions = @gauss                    % single function
%                     functions = {@gauss, @lorentzian}     % three functions
%
%               Generally:
%               - If the fit function is global, then give only one function
%                 handle: the same function applies to every dataset
%
%               - If the fit functions are local, then:
%                   - if every dataset to be fitted to the same function
%                    you can give just one function handle (the parameters
%                    will be independently fitted of course)
%                   - if the functions are different for different datasets
%                    give a cell array of function handles
%
%               Note: the above applies only to the subset of functions
%               selected by the optional argument ifun if it is given
%
%   pin         Parameter list or cell array of initial parameter lists. The
%              form of the parameter list is given below in the description of
%              the format of the fit function.
%               - If you give one initial parameter list, it is assumed to give
%                the starting parameters for every function.
%               - If you give a cell array of parameter lists, then there must
%                be one parameter list for each fit function.
%
%               This syntax allows an abbreviated argument list. For example,
%              if the fit function are local, three datasets, then :
%
%                   >> obj = obj.set_bfun (@gauss, [100,10,0.5])
%               Every dataset is independently fitted to a Gaussian with same
%              initial parameters
%
%                   >> obj = obj.set_bfun (@gauss, {[100,10,0.5], [120,10,1], {140,10,2})
%               Every dataset is independently fitted to a Gaussian with
%              different starting parameters
%
%               Note: the above applies only to the subset of functions
%               selected by the optional argument ifun if it is given
%
% Optional arguments:
%   ifun        Scalar or row vector of integers giving the index or indicies
%              of the functions to be set. For examnple, if there are three
%              datasets and the fit is local (i.e. each datset has independent
%              fit functions) then set the function to be Gaussians for the
%              first and third datasets and a Lorentzian for the second:
%                   >> obj = obj.set_bfun ([1,3], @gauss, {[100,10,0.5], [120,10,1]})
%                   >> obj = obj.set_bfun (2, @lorentzian, [50,10,2])
%
%   free        Logical row vector (single function) or cell array of logical
%              row vectors (more than one function) that define which parameters
%              are free to vary (corresponding element is true) or fixed
%              (corresponding element is false). Note that just like arguments
%              fun and pin, if the background is local, then if a single
%              logical array is given, it is assumed to apply to all fit functions
%              (or the subset selected by ifun, if given).
%              For full details of the syntax for fixing/freeing parameters,
%              see <a href="matlab:doc('mfclass/set_bfree');">set_bfree</a>
%
%   bind        Binding of one or more parameters to other parameters.
%              For full details of the syntax for binding parameters together,
%              see <a href="matlab:doc('mfclass/set_bbind');">set_bbind</a>
%
% See also set_local_background set_global_background set_bfree set_bbind
%
%
% Form of background fit functions
% --------------------------------
%   function ycalc = my_function (x1,x2,...,p)
%
% or, more generally:
%   function ycalc = my_function (x1,x2,...,p,c1,c2,...)
%
% where
%   x1,x2,... Array of x values, one array for each dimension
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
%     See <a href="matlab:doc('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:doc('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
%   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
%
%   type = 'back'
%   pre = 'b'
%   x_arg = 'x1,x2,...'
%   x_descr = 'x1,x2,... Array of x values, one array for each dimension'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_fun_intro> <type> <pre>
%   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
%
%     See <a href="matlab:doc('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:doc('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>
% <#doc_end:>
% -----------------------------------------------------------------------------

try
    obj = set_bfun@mfclass (obj, varargin{:});
catch ME
    error(ME.message)
end
