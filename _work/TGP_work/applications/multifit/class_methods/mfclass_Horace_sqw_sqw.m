classdef mfclass_Horace_sqw_sqw < mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    %
    % mfclass_Horace_sqw_sqw Methods:
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
    % mfclass_Horace_sqw_sqw Properties:
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

    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_doc_purpose_summary_file = fullfile(mfclass_doc,'doc_purpose_summary.m')
    %   mfclass_doc_methods_summary_file = fullfile(mfclass_doc,'doc_methods_summary.m')
    %   mfclass_doc_properties_summary_file = fullfile(mfclass_doc,'doc_properties_summary.m')
    %
    %   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
    %   Horace_doc_average_option = fullfile(mfclass_Horace_doc,'doc_average_option.m')
    %
    %   class_name = 'mfclass_Horace_sqw_sqw'
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
        function obj = mfclass_Horace_sqw_sqw (varargin)
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
            % <a href="matlab:edit('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
            % <a href="matlab:edit('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)

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

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
            %
            %   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
            %   doc_set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'doc_set_fun_sqw_model_form.m')
            %
            %   type = 'back'
            %   pre = 'b'
            % -----------------------------------------------------------------------------
            % <#doc_beg:> multifit
            %   <#file:> <doc_set_fun_intro> <type> <pre>
            %   <#file:> <doc_set_fun_sqw_model_form>
            %
            % <a href="matlab:edit('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
            % <a href="matlab:edit('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            try
                obj = set_bfun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

        function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
            % Perform a simulation of the data using the current functions and starting parameter values
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

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_simulate_intro = fullfile(mfclass_doc,'doc_simulate_intro.m')
            % <#doc_beg:> multifit
            %   <#file:> <doc_simulate_intro>
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            obj_tmp = obj;
            if obj.average && strcmp(obj.dataset_class,'sqw')
                wrapfun = obj.wrapfun;
                wrapfun.p_wrap = append_args (wrapfun.p_wrap, 'ave');
                wrapfun.bp_wrap = append_args (wrapfun.bp_wrap, 'ave');
                obj_tmp.wrapfun = wrapfun;
            end

            [data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
        end

        function [data_out, calcdata, ok, mess] = fit (obj)
            % Perform a fit of the data using the current functions and starting parameter values
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
            %
            % If ok is not a return argument, then if ok is false an error will be thrown.

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_fit_intro = fullfile(mfclass_doc,'doc_fit_intro.m')
            % <#doc_beg:> multifit
            %   <#file:> <doc_fit_intro>
            % <#doc_end:>
            % -----------------------------------------------------------------------------

            % Update parameter wrapping according to 'average' property
            obj_tmp = obj;
            if obj.average && strcmp(obj.dataset_class,'sqw')
                wrapfun = obj.wrapfun;
                wrapfun.p_wrap = append_args (wrapfun.p_wrap, 'ave');
                wrapfun.bp_wrap = append_args (wrapfun.bp_wrap, 'ave');
                obj_tmp.wrapfun = wrapfun;
            end
            [data_out, calcdata, ok, mess] = fit@mfclass (obj_tmp);
        end
    end
end
