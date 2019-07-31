% Description of function syntax for set_fun and set_bfun
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type  = '#1'    % 'back' or 'fore'
%   pre   = '#2'    % 'b' or ''
%   atype = '#3'    % 'back' or 'fore' (opposite of type)
%
%   not_fun = 0
%   is_fun = 1
%
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_arg_pin = fullfile(mfclass_doc,'doc_arg_pin.m')
%   doc_arg_free = fullfile(mfclass_doc,'doc_arg_free.m')
%   doc_arg_bind = fullfile(mfclass_doc,'doc_arg_bind.m')
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
% Set <type>ground function or functions
%
% Set all <type>ground functions
%   >> obj = obj.set_<pre>fun (fun)
%   >> obj = obj.set_<pre>fun (fun, pin)
%   >> obj = obj.set_<pre>fun (fun, pin, free)
%   >> obj = obj.set_<pre>fun (fun, pin, free, bind)
%   >> obj = obj.set_<pre>fun (fun, pin, 'free', free, 'bind', bind)
%
% Set a particular <type>ground function or set of <type>ground functions:
%   >> obj = obj.set_<pre>fun (ifun, fun,...)     % ifun is scalar or row vector
%
% Input:
% ------
%   fun     Function handle or cell array of function handles
%           e.g.  fun = @gauss                    % single function
%                 fun = {@gauss, @lorentzian}     % two functions
%
%           In general:
%           - If the fit function is global, then give only one function
%             handle: the same function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                give just one function handle (the parameters will be
%                independently fitted of course)
%
%               - if the functions are different for different datasets
%                give a cell array of function handles, one per dataset
%
%           Note: If a subset of functions is selected with the optional
%          parameter ifun, then the expansion of a single function
%          handle to an array applies only to that subset
%
% Optional arguments:
%   ifun    Scalar or row vector of integers giving the index or indicies
%          of the functions to be set. [Default: all functions]
%           EXAMPLE
%           If there are three datasets and the fit is local (i.e. each
%          datset has independent fit functions) then to set the function
%          to be Gaussians for the first and third datasets and a Lorentzian
%          for the second:
%              >> obj = obj.set_<pre>fun ([1,3], @gauss)
%              >> obj = obj.set_<pre>fun (2, @lorentzian)
%
%   <#file:> <doc_arg_pin>  <type> <pre> not_fun is_fun
%
%   <#file:> <doc_arg_free> <type> <pre> not_fun is_fun
%
%   <#file:> <doc_arg_bind> <type> <pre> <atype> not_fun is_fun set
%
%
% Form of <type>ground fit functions
% --------------------------------
% <#doc_end:>
% -----------------------------------------------------------------------------
