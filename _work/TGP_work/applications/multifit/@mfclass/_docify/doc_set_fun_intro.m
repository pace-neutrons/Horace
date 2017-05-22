% Description of function syntax for set_fun and set_bfun
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type = '#1'     % 'back' or 'fore'
%   pre  = '#2'     % 'b' or ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Set <type>ground function or functions
%
% Set all <type>ground functions
%   >> obj = obj.set_<pre>fun (functions, pin)
%   >> obj = obj.set_<pre>fun (functions, pin, free)
%   >> obj = obj.set_<pre>fun (functions, pin, free, bind)
%   >> obj = obj.set_<pre>fun (functions, pin, 'free', free, 'bind', bind)
%
% Set a particular <type>ground function or set of <type>ground functions:
%   >> obj = obj.set_<pre>fun (ifun, functions, pin,...)    % ifun is scalar or row vector
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
%                   >> obj = obj.set_<pre>fun (@gauss, [100,10,0.5])
%               Every dataset is independently fitted to a Gaussian with same
%              initial parameters
%
%                   >> obj = obj.set_<pre>fun (@gauss, {[100,10,0.5], [120,10,1], {140,10,2})
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
%                   >> obj = obj.set_<pre>fun ([1,3], @gauss, {[100,10,0.5], [120,10,1]})
%                   >> obj = obj.set_<pre>fun (2, @lorentzian, [50,10,2])
%
%   free        Logical row vector (single function) or cell array of logical
%              row vectors (more than one function) that define which parameters
%              are free to vary (corresponding element is true) or fixed
%              (corresponding element is false). Note that just like arguments
%              fun and pin, if the <type>ground is local, then if a single
%              logical array is given, it is assumed to apply to all fit functions
%              (or the subset selected by ifun, if given).
%              For full details of the syntax for fixing/freeing parameters,
%              see <a href="matlab:doc('mfclass/set_<pre>free');">set_<pre>free</a>
%
%   bind        Binding of one or more parameters to other parameters.
%              For full details of the syntax for binding parameters together,
%              see <a href="matlab:doc('mfclass/set_<pre>bind');">set_<pre>bind</a>
%
% See also set_local_<type>ground set_global_<type>ground set_<pre>free set_<pre>bind
%
%
% Form of <type>ground fit functions
% --------------------------------
% <#doc_end:>
