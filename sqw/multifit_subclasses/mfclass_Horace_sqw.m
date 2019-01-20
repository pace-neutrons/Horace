classdef mfclass_Horace_sqw < mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    %
    % mfclass_Horace_sqw Methods:
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
    %   set_pin      - Set background fit function parameters
    %   clear_pin    - Clear parameters for one or more background fit functions
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
    % In addtion, specifically for sqw object fitting:
    %   You can compute the fit function at the average qh, qk, ql for each bin
    %   rather than for each pixel by setting the 'average' property:
    %
    %   If myFitObj is a previously created instance of the fit object
    %       >> myFitObj = true;
    %
    %
    % mfclass_Horace_sqw Properties:
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
    %   mfclass_Horace_doc = fullfile(fileparts(which('mfclass_Horace')),'_docify')
    %   Horace_doc_average_option = fullfile(mfclass_Horace_doc,'doc_average_option.m')
    %
    %   class_name = 'mfclass_Horace_sqw'
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
    %   <#file:> <Horace_doc_average_option>
    %
    %
    % <class_name> Properties:
    % --------------------------------------
    %   <#file:> <mfclass_doc_properties_summary_file>
    % <#doc_end:>
    % -----------------------------------------------------------------------------


    properties
        average = false;
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_Horace_sqw (varargin)
            obj@mfclass(varargin{:});
        end

        %------------------------------------------------------------------
        % Set/get methods
        %------------------------------------------------------------------
        function obj = set.average (obj, val)
            if islognumscalar(val)
                obj.average = logical(val);
            else
                error ('Propery named ''average'' must be a logical scalar (or numeric 0 or 1)')
            end
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
            %               [par, fun]
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
            %               [par, fun]
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
            %     See <a href="matlab:edit('example_1d_function');">example_1d_function</a>
            %     See <a href="matlab:edit('example_2d_function');">example_2d_function</a>
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
            %   x_arg = 'x1,x2,...'
            %   x_descr = 'x1,x2,... Array of x values, one array for each dimension'
            %
            % -----------------------------------------------------------------------------
            % <#doc_beg:> multifit
            %   <#file:> <doc_set_fun_intro> <type> <pre> <atype>
            %   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
            %
            %     See <a href="matlab:edit('example_1d_function');">example_1d_function</a>
            %     See <a href="matlab:edit('example_2d_function');">example_2d_function</a>
            %     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            try
                obj = set_bfun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

        function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
            % Perform a simulation of the data using the current functions and parameter values
            %
            % Return calculated sum of foreground and background:
            %   >> [data_out, calcdata] = obj.simulate                % if ok false, throws error
            %
            % Return foreground, background, sum or all three:
            %   >> [data_out, calcdata] = obj.simulate ('sum')        % Equivalent to above
            %   >> [data_out, calcdata] = obj.simulate ('foreground') % calculate foreground only
            %   >> [data_out, calcdata] = obj.simulate ('background') % calculate background only
            %
            %   >> [data_out, calcdata] = obj.simulate ('components') % calculate foreground,
            %                                                         % background and sum
            %                                                         % (data_out is a structure)
            %
            % Continue execution even if an error condition is thrown:
            %   >> [data_out, calcdata, ok, mess] = obj.simulate (...) % if ok false, still returns
            %
            % If the results of a previous fit are available, with the same number of foreground
            % and background functions and parameters, then the fit parameter structure can be
            % passed as the first argument as the values at which to simulate the output:
            %   >> [data_out, fitdata] = obj.fit (...)
            %               :
            %   >> [...] = obj.simulate (fitdata, ...)
            %
            % (This is useful if you want to simulate the result of a fit without updating the
            % parameter values function-by-function)
            %
            % Output:
            % -------
            %  data_out Output with same form as input data but with y values evaluated
            %           at the initial parameter values. If the input was three separate
            %           x,y,e arrays, then only the calculated y values are returned.
            %           If there was a problem i.e. ok==false, then data_out=[].
            %
            %           If option is 'components', then data_out is a structure with fields
            %           with the same format as above, as follows:
            %               data_out.sum        Sum of foreground and background
            %               data_out.fore       Foreground calculation
            %               data_out.back       Background calculation
            %           If there was a problem i.e. ok==false, then each field is =[].
            %
            %  calcdata Structure with result of the fit for each dataset. The fields are:
            %           p      - Foreground parameter values (if foreground function(s) present)
            %                      If only one function, a row vector
            %                      If more than one function: a row cell array of row vectors
            %           sig    - Estimated errors of foreground parameters (=0 for fixed
            %                    parameters)
            %                      If only one function, a row vector
            %                      If more than one function: a row cell array of row vectors
            %           bp     - Background parameter values (if background function(s) present)
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
            %           If there was a problem i.e. ok==false, then calcdata=[].
            %
            %   ok      True:  Simulation performed
            %           False: Fundamental problem with the input arguments
            %
            %   mess    Message if ok==false; Empty string if ok==true.
            %
            %
            % If ok is not a return argument, then if ok is false an error will be thrown.

            % -----------------------------------------------------------------------------
            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_simulate_intro = fullfile(mfclass_doc,'doc_simulate_intro.m')
            % -----------------------------------------------------------------------------
            % <#doc_beg:> multifit
            %   <#file:> <doc_simulate_intro>
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            % Update parameter wrapping according to 'average' property
            obj_tmp = obj;
            if obj.average && strcmp(obj.dataset_class,'sqw')
                wrapfun = obj.wrapfun;
                wrapfun.p_wrap = append_args (wrapfun.p_wrap, 'ave');
                obj_tmp.wrapfun = wrapfun;
            end
            [data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
        end

        function [data_out, calcdata, ok, mess] = fit (obj, varargin)
            % Perform a fit of the data using the current functions and parameter values
            %
            % Return calculated fitted datasets and parameters:
            %   >> [data_out, fitdata] = obj.fit                    % if ok false, throws error
            %
            % Return the calculated fitted signal, foreground and background in a structure:
            %   >> [data_out, fitdata] = obj.fit ('components')     % if ok false, throws error
            %
            % Continue execution even if an error condition is thrown:
            %   >> [data_out, fitdata, ok, mess] = obj.fit (...)    % if ok false, still returns
            %
            % If the results of a previous fit are available, with the same number of foreground
            % and background functions and parameters, then the fit parameter structure can be
            % passed as the first argument as the initial values at which to satart the fit:
            %   >> [data_out, fitdata] = obj.fit (...)
            %               :
            %   >> [...] = obj.fit (fitdata, ...)
            %
            % (This is useful if you want to re-fit starting with the results of an earlier fit)
            %
            %
            % Output:
            % -------
            %  data_out Output with same form as input data but with y values evaluated
            %           at the final fit parameter values. If the input was three separate
            %           x,y,e arrays, then only the calculated y values are returned.
            %           If there was a problem i.e. ok==false, then data_out=[].
            %
            %           If option 'components' was given, then data_out is a structure with fields
            %           with the same format as above, as follows:
            %               data_out.sum        Sum of foreground and background
            %               data_out.fore       Foreground calculation
            %               data_out.back       Background calculation
            %           If there was a problem i.e. ok==false, then each field is =[].
            %
            %   fitdata Structure with result of the fit for each dataset. The fields are:
            %           p      - Foreground parameter values (if foreground function(s) present)
            %                      If only one function, a row vector
            %                      If more than one function: a row cell array of row vectors
            %           sig    - Estimated errors of foreground parameters (=0 for fixed
            %                    parameters)
            %                      If only one function, a row vector
            %                      If more than one function: a row cell array of row vectors
            %           bp     - Background parameter values (if background function(s) present)
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
            %   mess    Message if ok==false; Empty string if ok==true.
            %
            % If ok is not a return argument, then if ok is false an error will be thrown.

            % -----------------------------------------------------------------------------
            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_fit_intro = fullfile(mfclass_doc,'doc_fit_intro.m')
            % -----------------------------------------------------------------------------
            % <#doc_beg:> multifit
            %   <#file:> <doc_fit_intro> '' ''
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            % Update parameter wrapping according to 'average' property
            obj_tmp = obj;
            if obj.average && strcmp(obj.dataset_class,'sqw')
                wrapfun = obj.wrapfun;
                wrapfun.p_wrap = append_args (wrapfun.p_wrap, 'ave');
                obj_tmp.wrapfun = wrapfun;
            end
            [data_out, calcdata, ok, mess] = fit@mfclass (obj_tmp, varargin{:});
        end
    end
end
