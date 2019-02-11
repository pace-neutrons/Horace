classdef mfclass_IX_dataset_3d < mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    %
    % mfclass_IX_dataset_3d Methods:
    % --------------------------------------
    % To set data:
    %   set_data     - Set data, clearing any existing datasets
    %   append_data  - Append further datasets to the current set of datasets
    %   remove_data  - Remove one or more dataset(s)
    %   replace_data - Replace one or more dataset(s)
    %
    % To mask data points:
    %   set_mask     - Mask data points
    %   add_mask     - Mask additional data points
    %   clear_mask   - Clear masking for one or more dataset(s)
    %
    % To set fitting functions:
    %   set_fun      - Set foreground fit functions
    %   clear_fun    - Clear one or more foreground fit functions
    %
    %   set_bfun     - Set background fit functions
    %   clear_bfun   - Clear one or more background fit functions
    %
    % To set initial function parameter values:
    %   set_pin      - Set foreground fit function parameters
    %   clear_pin    - Clear parameters for one or more foreground fit functions
    %
    %   set_bpin     - Set background fit function parameters
    %   clear_bpin   - Clear parameters for one or more background fit functions
    %
    % To set which parameters are fixed or free:
    %   set_free     - Set free or fix foreground function parameters
    %   clear_free   - Clear all foreground parameters to be free for one or more data sets
    %
    %   set_bfree    - Set free or fix background function parameters
    %   clear_bfree  - Clear all background parameters to be free for one or more data sets
    %
    % To bind parameters:
    %   set_bind     - Bind foreground parameter values in fixed ratios
    %   add_bind     - Add further foreground function bindings
    %   clear_bind   - Clear parameter bindings for one or more foreground functions
    %
    %   set_bbind    - Bind background parameter values in fixed ratios
    %   add_bbind    - Add further background function bindings
    %   clear_bbind  - Clear parameter bindings for one or more background functions
    %
    % To set functions as operating globally or local to a single dataset
    %   set_global_foreground - Specify that there will be a global foreground fit function
    %   set_local_foreground  - Specify that there will be local foreground fit function(s)
    %
    %   set_global_background - Specify that there will be a global background fit function
    %   set_local_background  - Specify that there will be local background fit function(s)
    %
    % To fit or simulate:
    %   fit          - Fit data
    %   simulate     - Simulate datasets at the initial parameter values
    %
    % Fit control parameters and other options:
    %   set_options  - Set options
    %   get_options  - Get values of one or more specific options
    %
    %
    % mfclass_IX_dataset_3d Properties:
    % --------------------------------------
    % Data to be fitted:
    %   data         - datasets to be fitted or simulated
    %   mask         - mask arrays to remove data points from fitting or simulation
    %
    % Fit functions:
    %   fun          - foreground fit function handles
    %   pin          - foreground function parameter values
    %   free         - the foreground function parameters that can vary in a fit
    %   bind         - binding of foreground parameters to free parameters
    %
    %   bfun         - foreground fit function handles
    %   bpin         - foreground function parameter values
    %   bfree        - the foreground function parameters that can vary in a fit
    %   bbind        - binding of foreground parameters to free parameters
    %
    % To set functions as operating globally or local to a single dataset
    %   global_foreground - true if a global foreground fit function
    %   local_foreground  - true if a local foreground fit functions
    %   global_background - true if a global background fit function
    %   local_background  - true if a local background fit function(s)
    %
    % Options:
    %   options      - options defining fit control parameters

    % -----------------------------------------------------------------------------
    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_doc_purpose_summary_file = fullfile(mfclass_doc,'doc_purpose_summary.m')
    %   mfclass_doc_methods_summary_file = fullfile(mfclass_doc,'doc_methods_summary.m')
    %   mfclass_doc_properties_summary_file = fullfile(mfclass_doc,'doc_properties_summary.m')
    %
    %   class_name = 'mfclass_IX_dataset_3d'
    %
    % -----------------------------------------------------------------------------
    % <#doc_beg:> multifit
    %   <#file:> <mfclass_doc_purpose_summary_file>
    %
    %
    % <class_name> Methods:
    % --------------------------------------
    %   <#file:> <mfclass_doc_methods_summary_file>
    %
    %
    % <class_name> Properties:
    % --------------------------------------
    %   <#file:> <mfclass_doc_properties_summary_file>
    % <#doc_end:>
    % -----------------------------------------------------------------------------


    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_IX_dataset_3d (varargin)
            obj@mfclass(varargin{:});
        end

        %------------------------------------------------------------------
        % Extend superclass methods
        %------------------------------------------------------------------
        % Extend set_fun and set_bfun solely to provide tailored documentation

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
            %   function ycalc = my_function (x1,x2,x3,p)
            %
            % or, more generally:
            %   function ycalc = my_function (x1,x2,x3,p,c1,c2,...)
            %
            % where
            %   x1,x2,x3    Arrays of x values along first, second and third dimensions
            %   p           A vector of numeric parameters that define the
            %              function (e.g. [A,x0,w] as area, position and
            %              width of a peak)
            %   c1,c2,...   Any further arguments needed by the function (e.g.
            %              they could be the filenames of lookup tables)
            %
            %     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>

            % -----------------------------------------------------------------------------
            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
            %   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
            %
            %   type = 'fore'
            %   pre = ''
            %   atype = 'back'
            %   x_arg = 'x1,x2,x3'
            %   x_descr = 'x1,x2,x3    Arrays of x values along first, second and third dimensions'
            %
            % -----------------------------------------------------------------------------
            % <#doc_beg:> multifit
            %   <#file:> <doc_set_fun_intro> <type> <pre> <atype>
            %   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
            %
            %     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            try
                obj = set_fun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

        function obj = set_bfun(obj,varargin)
            % Set background function or functions
            %
            % Set all background functions
            %   >> obj = obj.set_bfun (fun)
            %   >> obj = obj.set_bfun (fun, pin)
            %   >> obj = obj.set_bfun (fun, pin, free)
            %   >> obj = obj.set_bfun (fun, pin, free, bind)
            %   >> obj = obj.set_bfun (fun, pin, 'free', free, 'bind', bind)
            %
            % Set a particular background function or set of background functions:
            %   >> obj = obj.set_bfun (ifun, fun,...)     % ifun is scalar or row vector
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
            %              >> obj = obj.set_bfun ([1,3], @gauss)
            %              >> obj = obj.set_bfun (2, @lorentzian)
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
            %               >> obj = obj.set_bfun (@gauss, [100,10,0.5])
            %
            %               fits the datasets independently to Gaussians starting
            %               with the same initial parameters
            %
            %               >> obj = obj.set_bfun (@gauss, {[100,10,0.5], [140,10,2]})
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
            %                   background parameter to be bound
            %
            %               [ipar_free, ifun_free]
            %                   Parameter index and function index of the
            %                   parameter to which the bound parameter is tied.
            %                   The function index is positive for background
            %                   functions, negative for foreground functions.
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
            %             The descriptor applies for all background functions, or if
            %            the optional first input argument ifun is given to those
            %            background functions
            %
            %               { ipar_bound, [ipar_free, ifun_free] }
            %         *OR*  { ipar_bound, [ipar_free, ifun_free], ratio }
            %
            %           EXAMPLE
            %               {2, [2,1]}  % bind parameter 2 of every background function
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
            %               {[2,3], 6}  % bind parameter 2 of background function 3
            %                           % to parameter 6 of the same function
            %
            %           - Both ifun_bound and ifun_free missing:
            %             --------------------------------------
            %             Combines the above two cases: the descriptor applies for all
            %            background functions (or those functions given by the
            %            optional argument ifun described below), and that the unbound
            %            parameter has the same  function index as the bound parameter
            %            in each instance
            %
            %               { ipar_bound, ipar_free }
            %         *OR*  { ipar_bound, ipar_free, ratio }
            %
            %           EXAMPLE
            %               {2,5}       % bind parameter 2 to parameter 5 of the same
            %                           % function, for every background function
            %
            %
            % Form of background fit functions
            % --------------------------------
            %   function ycalc = my_function (x1,x2,x3,p)
            %
            % or, more generally:
            %   function ycalc = my_function (x1,x2,x3,p,c1,c2,...)
            %
            % where
            %   x1,x2,x3    Arrays of x values along first, second and third dimensions
            %   p           A vector of numeric parameters that define the
            %              function (e.g. [A,x0,w] as area, position and
            %              width of a peak)
            %   c1,c2,...   Any further arguments needed by the function (e.g.
            %              they could be the filenames of lookup tables)
            %
            %     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>

            % -----------------------------------------------------------------------------
            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
            %   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
            %
            %   type = 'back'
            %   pre = 'b'
            %   atype = 'fore'
            %   x_arg = 'x1,x2,x3'
            %   x_descr = 'x1,x2,x3    Arrays of x values along first, second and third dimensions'
            %
            % -----------------------------------------------------------------------------
            % <#doc_beg:> multifit
            %   <#file:> <doc_set_fun_intro> <type> <pre> <atype>
            %   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
            %
            %     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            try
                obj = set_bfun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

    end
end
