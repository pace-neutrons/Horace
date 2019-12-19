function obj = set_fun(obj,varargin)
% Set foreground function or functions
%
% Set all foreground functions
%   >> obj = obj.set_fun (fun)
%   >> obj = obj.set_fun (fun, pin)
%   >> obj = obj.set_fun (fun, pin, free)
%   >> obj = obj.set_fun (fun, pin, free, bind)
%   >> obj = obj.set_fun (fun, pin, 'free', free, 'bind', bind)
%
% Set a particular foreground function or set of foreground functions:
%   >> obj = obj.set_fun (ifun, fun,...)     % ifun is scalar or row vector
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
%              >> obj = obj.set_fun ([1,3], @gauss)
%              >> obj = obj.set_fun (2, @lorentzian)
%
%   pin     Initial parameter list or a cell array of initial parameter
%          lists. Depending on the function, the form of the parameter
%          list is either:
%               p
%          or:
%               {p,c1,c2,...}
%          where
%               p           A vector of numeric parameters that define
%                          the function (e.g. [A,x0,w] as area, position
%                          and width of a peak)
%               c1,c2,...   Any further constant arguments needed by the
%                          function e.g. the filenames of lookup tables)
%
%           In general:
%           - If the fit function is global, then give only one parameter
%             list: the one function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                and with the same initial parameter values, you can
%                give just one parameter list. The parameters will be
%                fitted independently (subject to any bindings that
%                can be set elsewhere)
%
%               - if the functions are different for different datasets
%                or the intiial parmaeter values are different, give a
%                cell array of function handles, one per dataset
%
%           This syntax allows an abbreviated argument list. For example,
%          if there are two datsets and the fit functions are local then:
%
%               >> obj = obj.set_fun (@gauss, [100,10,0.5])
%
%               fits the datasets independently to Gaussians starting
%               with the same initial parameters
%
%               >> obj = obj.set_fun (@gauss, {[100,10,0.5], [140,10,2]})
%
%               fits the datasets independently to Gaussians starting
%               with the different initial parameters
%
%           Note: If a subset of functions is selected with the optional
%          parameter ifun, then the expansion of a single parameter list
%          to an array applies only to that subset
%
%   free    Logical row vector or cell array of logical row vectors that
%          define which parameters are free to float in a fit.
%           Each element of a row vector consists of logical true or
%          false (or 1 or 0) indicating if the corresponding parameter
%          for a function is free to float during a fit or is fixed.
%
%           In general:
%           - If the fit function is global, then give only one row
%             vector: the one function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                you can give just one vector of fixed/float values if
%                you want the same parameters to be fixed or floating
%                for each dataset, even if the initial values are
%                different.
%
%               - if the functions are different for different datasets
%                or the float status of the parameters is different for
%                different datasets, give a cell array of function
%                handles, one per dataset
%
%   bind    Binding of one or more parameters to other parameters.
%           In general, bind has the form:
%               {b1, b2, ...}
%           where b1, b2 are binding descriptors.
%
%           Each binding descriptor is a cell array with the form:
%               { [ipar_bound, ifun_bound], [ipar_free, ifun_free] }
%         *OR*  { [ipar_bound, ifun_bound], [ipar_free, ifun_free], ratio }
%
%           where
%               [ipar_bound, ifun_bound]
%                   Parameter index and function index of the
%                   foreground parameter to be bound
%
%               [ipar_free, ifun_free]
%                   Parameter index and function index of the
%                   parameter to which the bound parameter is tied.
%                   The function index is positive for foreground
%                   functions, negative for background functions.
%
%               ratio
%                   Ratio of bound parameter value to floating
%                   parameter. If not given, or ratio=NaN, then the
%                   ratio is set from the initial parameter values
%
%           Binding descriptors that set multiple bindings
%           ----------------------------------------------
%           If ifun_bound and/or ifun_free are omitted a binding
%          descriptor has a more general interpretation that makes it
%          simple to specify bindings for many functions:
%
%           - ifun_bound missing:
%             -------------------
%             The descriptor applies for all foreground functions, or if
%            the optional first input argument ifun is given to those
%            foreground functions
%
%               { ipar_bound, [ipar_free, ifun_free] }
%         *OR*  { ipar_bound, [ipar_free, ifun_free], ratio }
%
%           EXAMPLE
%               {2, [2,1]}  % bind parameter 2 of every foreground function
%                           % to parameter 2 of the first function
%                           % (Effectively makes parameter 2 global)
%
%           - ifun_free missing:
%             ------------------
%             The descriptor assumes that the unbound parameter has the same
%            function index as the bound parameter
%
%               { [ipar_bound, ifun_bound], ipar_free }
%         *OR*  { [ipar_bound, ifun_bound], ipar_free, ratio }
%
%           EXAMPLE
%               {[2,3], 6}  % bind parameter 2 of foreground function 3
%                           % to parameter 6 of the same function
%
%           - Both ifun_bound and ifun_free missing:
%             --------------------------------------
%             Combines the above two cases: the descriptor applies for all
%            foreground functions (or those functions given by the
%            optional argument ifun described below), and that the unbound
%            parameter has the same  function index as the bound parameter
%            in each instance
%
%               { ipar_bound, ipar_free }
%         *OR*  { ipar_bound, ipar_free, ratio }
%
%           EXAMPLE
%               {2,5}       % bind parameter 2 to parameter 5 of the same
%                           % function, for every foreground function
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
% <a href="matlab:edit('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:edit('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
%
%   mfclass_Horace_doc = fullfile(fileparts(which('mfclass_Horace')),'_docify')
%   doc_set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'doc_set_fun_sqw_model_form.m')
%
%   type = 'fore'
%   pre = ''
%   atype = 'back'
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_fun_intro> <type> <pre> <atype>
%   <#file:> <doc_set_fun_sqw_model_form>
%
% <a href="matlab:edit('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:edit('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
% <#doc_end:>
% -----------------------------------------------------------------------------

try
    obj = set_fun@mfclass (obj, varargin{:});
catch ME
    error(ME.message)
end
