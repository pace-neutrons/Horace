function obj = set_fun(obj,varargin)
% Set foreground function or functions
%
% Set all foreground functions
%   >> obj = obj.set_fun (functions, pin)
%   >> obj = obj.set_fun (functions, pin, free)
%   >> obj = obj.set_fun (functions, pin, free, bind)
%   >> obj = obj.set_fun (functions, pin, 'free', free, 'bind', bind)
%
% Set a particular foreground function or set of foreground functions:
%   >> obj = obj.set_fun (ifun, functions, pin,...)    % ifun is scalar or row vector
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
%                   >> obj = obj.set_fun (@gauss, [100,10,0.5])
%               Every dataset is independently fitted to a Gaussian with same
%              initial parameters
%
%                   >> obj = obj.set_fun (@gauss, {[100,10,0.5], [120,10,1], {140,10,2})
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
%                   >> obj = obj.set_fun ([1,3], @gauss, {[100,10,0.5], [120,10,1]})
%                   >> obj = obj.set_fun (2, @lorentzian, [50,10,2])
%
%   free        Logical row vector (single function) or cell array of logical
%              row vectors (more than one function) that define which parameters
%              are free to vary (corresponding element is true) or fixed
%              (corresponding element is false). Note that just like arguments
%              fun and pin, if the foreground is local, then if a single
%              logical array is given, it is assumed to apply to all fit functions
%              (or the subset selected by ifun, if given).
%              For full details of the syntax for fixing/freeing parameters,
%              see <a href="matlab:doc('mfclass/set_free');">set_free</a>
%
%   bind        Binding of one or more parameters to other parameters.
%              For full details of the syntax for binding parameters together,
%              see <a href="matlab:doc('mfclass/set_bind');">set_bind</a>
%
% See also set_local_foreground set_global_foreground set_free set_bind
%
%
% Form of foreground fit functions
% --------------------------------
% A model for S(Q,w) must have the form:
%
%       function ycalc = my_function (qh, qk, ql, en, par)
%
% More generally:
%       function ycalc = my_function (qh, qk, ql, en, par, c1, c2,...)
%
% where
%   qh, qk, qk  Arrays of h, k, l in reciprocal lattice vectors, one element
%              of the arrays for each data point
%   en          Array of energy transfers at those points
%   par         A vector of numeric parameters that define the
%              function (e.g. [A,J1,J2] as scale factor and exchange parmaeters
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
%
%   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
%   doc_set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'doc_set_fun_sqw_model_form.m')
%
%   type = 'fore'
%   pre = ''
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_fun_intro> <type> <pre>
%   <#file:> <doc_set_fun_sqw_model_form>
%
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
% <#doc_end:>
% -----------------------------------------------------------------------------

try
    obj = set_fun@mfclass (obj, varargin{:});
catch ME
    error(ME.message)
end
