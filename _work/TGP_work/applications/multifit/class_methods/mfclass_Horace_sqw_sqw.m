classdef mfclass_Horace_sqw_sqw < mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    % mfclass_Horace_sqw_sqw Methods:
    %
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
    %   set_bfun     - Set background fit functions
    %   clear_fun    - Clear one or more foreground fit functions
    %   clear_bfun   - Clear one or more background fit functions
    %
    % To set which parameters are fixed or free:
    %   set_free     - Set free or fix foreground function parameters
    %   set_bfree    - Set free or fix background function parameters
    %   clear_free   - Clear all foreground parameters to be free for one or more data sets
    %   clear_bfree  - Clear all background parameters to be free for one or more data sets
    %
    % To bind parameters:
    %   set_bind     - Bind foreground parameter values in fixed ratios
    %   set_bbind    - Bind background parameter values in fixed ratios
    %   add_bind     - Add further foreground function bindings
    %   add_bbind    - Add further background function bindings
    %   clear_bind   - Clear parameter bindings for one or more foreground functions
    %   clear_bbind  - Clear parameter bindings for one or more background functions
    %
    % To set functions as operating globally or local to a single dataset
    %   set_global_foreground - Specify that there will be a global foreground fit function
    %   set_global_background - Specify that there will be a global background fit function
    %   set_local_foreground  - Specify that there will be local foreground fit function(s)
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

    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_purpose_summary_file = fullfile(mfclass_doc,'purpose_summary.m')
    %   mfclass_methods_summary_file = fullfile(mfclass_doc,'methods_summary.m')
    %
    %   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
    %   Horace_average_option = fullfile(mfclass_Horace_doc,'average_option.m')
    %
    %   class_name = 'mfclass_Horace_sqw_sqw'
    %
    % <#doc_beg:> multifit
    %   <#file:> <mfclass_purpose_summary_file>
    %
    % <class_name> Methods:
    %
    %   <#file:> <mfclass_methods_summary_file>
    %
    %   <#file:> <Horace_average_option>
    % <#doc_end:>


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
            %   >> obj = obj.set_fun (@fhandle, pin)
            %   >> obj = obj.set_fun (@fhandle, pin, free)
            %   >> obj = obj.set_fun (@fhandle, pin, free, bind)
            %   >> obj = obj.set_fun (@fhandle, pin, 'free', free, 'bind', bind)
            %
            % Set a particular foreground function or set of foreground functions
            %   >> obj = obj.set_fun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector
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

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   set_fun_intro = fullfile(mfclass_doc,'set_fun_intro.m')
            %
            %   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
            %   set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'set_fun_sqw_model_form.m')
            %
            % <#doc_beg:> multifit
            %   <#file:> <set_fun_intro>
            %   <#file:> <set_fun_sqw_model_form>
            %
            % <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
            % <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
            % <#doc_end:>

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
            %   >> obj = obj.set_bfun (@fhandle, pin)
            %   >> obj = obj.set_bfun (@fhandle, pin, free)
            %   >> obj = obj.set_bfun (@fhandle, pin, free, bind)
            %   >> obj = obj.set_bfun (@fhandle, pin, 'free', free, 'bind', bind)
            %
            % Set a particular background function or set of background functions
            %   >> obj = obj.set_bfun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector
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
            % <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
            % <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   set_bfun_intro = fullfile(mfclass_doc,'set_bfun_intro.m')
            %
            %   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
            %   set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'set_fun_sqw_model_form.m')
            %
            % <#doc_beg:> multifit
            %   <#file:> <set_bfun_intro>
            %   <#file:> <set_fun_sqw_model_form>
            %
            % <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
            % <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
            % <#doc_end:>

            try
                obj = set_bfun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

        function [data_out, calcdata, ok, mess] = simulate (obj, varargin)
            % Perform a simulation of the data using the current functions and starting parameter values
            %
            %   >> [data_out, calcdata] = obj.simulate              % if ok false, throws error
            %   >> [data_out, calcdata] = obj.simulate ('fore')     % calculate foreground only
            %   >> [data_out, calcdata] = obj.simulate ('back')     % calculate background only
            %
            %   >> [data_out, calcdata, ok, mess] = obj.simulate (...) % if ok false, still returns
            %
            % Output:
            % -------
            %  data_out Output with same form as input data but with y values evaluated
            %           at the initial parameter values. If the input was three separate
            %           x,y,e arrays, then only the calculated y values are returned.
            %
            %           If there was a problem i.e. ok==false, then data_out=[].
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
            %   simulate_intro = fullfile(mfclass_doc,'simulate_intro.m')
            % <#doc_beg:> multifit
            %   <#file:> <simulate_intro>
            % <#doc_end:>

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
            %   >> [data_out, fitdata] = obj.fit            % if ok false, throws error
            %
            %   >> [data_out, fitdata, ok, mess] = obj.fit  % if ok false, still returns
            %
            %
            % Output:
            % -------
            %  data_out Output with same form as input data but with y values evaluated
            %           at the final fit parameter values. If the input was three separate
            %           x,y,e arrays, then only the calculated y values are returned.
            %
            %           If there was a problem i.e. ok==false, then data_out=[].
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
            %   fit_intro = fullfile(mfclass_doc,'fit_intro.m')
            % <#doc_beg:> multifit
            %   <#file:> <fit_intro>
            % <#doc_end:>

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
