classdef mfclass_tobyfit < mfclass
    % Simultaneously fits resolution broadened S(Q,w) models to several sqw
    % objects, with optional background functions. The foreground function(s)
    % and background function(s) can be set to apply globally to all datasets,
    % or locally, one function per dataset.
    %
    %
    % mfclass_tobyfit Methods:
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
    % In addtion, specifically for Tobyfit:
    %   set_mc_contributions    - Alter which components contribute to the resolution
    %   set_mc_points           - Set the number of Monte Carlo points per pixel
    %   set_refine_crystal      - Refine crystal lattice parmaeters and orientation
    %   set_refine_moderator    - Refine moderator parameters
    %
    %
    % mfclass_tobyfit Properties:
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
    %
    % In addition, specifically for Tobyfit:
    %   mc_contributions    - Defines which components contribute to the resolution
    %   mc_points           - The number of Monte Carlo points per pixel
    %   refine_crystal      - Crystal orientation refinement parameters
    %   refine_moderator    - Moderator parameter refinement parameters

    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_tobyfit_doc = fullfile(fileparts(which('mfclass_tobyfit')),'_docify')
    %
    %   mfclass_tobyfit_doc_purpose_summary_file = fullfile(mfclass_tobyfit_doc,'doc_purpose_summary.m')
    %   mfclass_doc_methods_summary_file = fullfile(mfclass_doc,'doc_methods_summary.m')
    %   mfclass_tobyfit_doc_methods_summary_file = fullfile(mfclass_tobyfit_doc,'doc_methods_summary.m')
    %   mfclass_doc_properties_summary_file = fullfile(mfclass_doc,'doc_properties_summary.m')
    %   mfclass_tobyfit_doc_properties_summary_file = fullfile(mfclass_tobyfit_doc,'doc_properties_summary.m')
    %
    %   class_name = 'mfclass_tobyfit'
    %
    % <#doc_beg:> multifit
    %   <#file:> <mfclass_tobyfit_doc_purpose_summary_file>
    %
    %
    % <class_name> Methods:
    % --------------------------------------
    %   <#file:> <mfclass_doc_methods_summary_file>
    %
    %   <#file:> <mfclass_tobyfit_doc_methods_summary_file>
    %
    %
    % <class_name> Properties:
    % --------------------------------------
    %   <#file:> <mfclass_doc_properties_summary_file>
    %
    %   <#file:> <mfclass_tobyfit_doc_properties_summary_file>
    % <#doc_end:>

    properties (Access=private, Hidden=true)
        mc_contributions_ = [];
        mc_points_ = [];
        refine_crystal_ = [];
        refine_moderator_ = [];
    end

    properties (Dependent)
        % Define which components of instrument contribute to resolution function model
        mc_contributions

        % The number of Monte Carlo points per pixel
        mc_points

        % Crystal orientation refinement parameters
        % If crystal refinement will not to be performed, contains [];
        % otherwise a structure with parameters:
        %   alatt       Initial lattice parameters
        %   angdeg      Initial lattice angles
        %   rot         Initial rotation vector (rad) (=[0,0,0])
        %   urot        x-axis in r.l.u. (Default: [1,0,0])
        %   vrot        Defines y-axis in r.l.u. (in plane of urot and vrot)
        %               (Default: [0,1,0])
        %   free        Logical row vector (length=9) (0 fixed, 1 free)
        %               (Default: all free)
        %   fix_alatt_ratio     =true if a,b,c are to be bound (Default: false)
        refine_crystal

        % Moderator parameter refinement parameters
        % If moderator refinement will not to be performed, contains [];
        % otherwise a structure with parameters:
        %	pulse_model     Name of moderator pulse shape model
        %   pin             Pulse shape parameters (row vector)
        %   free            Logical row vector of zeros and ones (0 fixed, 1 free)
        refine_moderator
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_tobyfit (varargin)
            obj@mfclass(varargin{:});
            obj = obj.set_mc_contributions;
            obj = obj.set_mc_points;
            obj = obj.set_refine_crystal (false);
            obj = obj.set_refine_moderator (false);
        end

        %------------------------------------------------------------------
        % Set/get methods
        %------------------------------------------------------------------
        function out = get.mc_contributions (obj)
            out = obj.mc_contributions_;
        end

        function out = get.mc_points (obj)
            out = obj.mc_points_;
        end

        function out = get.refine_crystal (obj)
            out = obj.refine_crystal_;
        end

        function out = get.refine_moderator (obj)
            out = obj.refine_moderator_;
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
            %   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
            %
            %   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
            %   doc_set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'doc_set_fun_sqw_model_form.m')
            %
            % <#doc_beg:> multifit
            %   <#file:> <doc_set_fun_intro>
            %   <#file:> <doc_set_fun_sqw_model_form>
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

        %------------------------------------------------------------------
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

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   doc_set_bfun_intro = fullfile(mfclass_doc,'doc_set_bfun_intro.m')
            %   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
            %
            %   class_name = 'mfclass_Horace'
            %   x_arg = 'x1,x2,...'
            %   x_descr = 'x1,x2,... Array of x values, one array for each dimension'
            %
            % <#doc_beg:> multifit
            %   <#file:> <doc_set_bfun_intro>
            %   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
            %
            %     See <a href="matlab:doc('example_1d_function');">example_1d_function</a>
            %     See <a href="matlab:doc('example_2d_function');">example_2d_function</a>
            %     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>
            % <#doc_end:>

            try
                obj = set_bfun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

        %------------------------------------------------------------------
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
            %   doc_simulate_intro = fullfile(mfclass_doc,'doc_simulate_intro.m')
            % <#doc_beg:> multifit
            %   <#file:> <doc_simulate_intro>
            % <#doc_end:>

            % Check there is data
            data = obj.data;
            if isempty(data)
                error('No data sets have been set - nothing to simulate')
            end

            % Update parameter wrapping
            obj_tmp = obj;
            obj_tmp.wrapfun.p_wrap = append_args (obj_tmp.wrapfun.p_wrap, obj.mc_contributions, obj.mc_points, [], []);

            % Perform simulation
            [data_out, calcdata, ok, mess] = simulate@mfclass (obj_tmp, varargin{:});
        end

        %------------------------------------------------------------------
        function [data_out, fitdata, ok, mess, varargout] = fit (obj)
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
            %   doc_fit_intro = fullfile(mfclass_doc,'doc_fit_intro.m')
            % <#doc_beg:> multifit
            %   <#file:> <doc_fit_intro>
            % <#doc_end:>

            % Check there is data
            data = obj.data;
            if isempty(data)
                error('No data sets have been set - nothing to fit')
            end

            % Update parameter wrapping
            obj_tmp = obj;

            is_refine_crystal = ~isempty(obj_tmp.refine_crystal);
            if is_refine_crystal
                [ok, mess, obj_tmp, xtal] = refine_crystal_pack_parameters_ (obj_tmp);
                if ~ok, error(mess), end
            else
                xtal = [];
            end

            is_refine_moderator = ~isempty(obj_tmp.refine_moderator);
            if is_refine_moderator
                [ok, mess, obj_tmp, modshape] = refine_moderator_pack_parameters_ (obj_tmp);
                if ~ok, error(mess), end
            else
                modshape = [];
            end

            obj_tmp.wrapfun.p_wrap = append_args (obj_tmp.wrapfun.p_wrap, obj.mc_contributions, obj.mc_points, xtal, modshape);

            % Perform fit
            [data_out, fitdata, ok, mess] = fit@mfclass (obj_tmp);

            % Extract crystal or moderator refinement parameters (if any) in a useful form
            if is_refine_crystal
                % Get the rlu correction matrix if crystal refinement
                if ~iscell(fitdata.p)   % single function
                    pxtal=fitdata.p(end-8:end);
                else
                    pxtal=fitdata.p{1}(end-8:end);
                end
                alatt=pxtal(1:3);
                angdeg=pxtal(4:6);
                rotvec=pxtal(7:9);
                rotmat=rotvec_to_rotmat2(rotvec);
                ub=ubmatrix(xtal.urot,xtal.vrot,bmatrix(alatt,angdeg));
                rlu_corr=ub\rotmat*xtal.ub0;
                % Pack output arguments
                varargout={rlu_corr};
            end

            if is_refine_moderator
                % Get the moderator refinement parameters
                fitmod.pulse_model=modshape.pulse_model;
                npmod=numel(modshape.pin);
                if ~iscell(fitdata.p)   % single function
                    fitmod.p=fitdata.p(end-npmod+1:end);
                    fitmod.sig=fitdata.sig(end-npmod+1:end);
                else
                    fitmod.p=fitdata.p{1}(end-npmod+1:end);
                    fitmod.sig=fitdata.sig{1}(end-npmod+1:end);
                end
                % Pack output arguments
                varargout={fitmod.pulse_model,fitmod.p,fitmod.sig};
            end
        end
    end

    methods (Access=private)
        %------------------------------------------------------------------
        % Methods in the defining folder but which need to be kept private
        %------------------------------------------------------------------
        [ok, mess, obj, xtal] = refine_crystal_pack_parameters_ (obj, xtal_opts)
        [ok, mess, obj, modshape] = refine_moderator_pack_parameters_ (obj, mod_opts)
    end
end
