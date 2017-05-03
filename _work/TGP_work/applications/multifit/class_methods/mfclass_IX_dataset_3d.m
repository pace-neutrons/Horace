classdef mfclass_IX_dataset_3d < mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    % mfclass_IX_dataset_3d Methods:
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

    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_purpose_summary_file = fullfile(mfclass_doc,'purpose_summary.m')
    %   mfclass_methods_summary_file = fullfile(mfclass_doc,'methods_summary.m')
    %
    %   class_name = 'mfclass_IX_dataset_3d'
    %
    % <#doc_beg:> multifit
    %   <#file:> <mfclass_purpose_summary_file>
    %
    % <class_name> Methods:
    %
    %   <#file:> <mfclass_methods_summary_file>
    % <#doc_end:>

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
            %     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   set_fun_intro = fullfile(mfclass_doc,'set_fun_intro.m')
            %   set_fun_xye_function_form = fullfile(mfclass_doc,'set_fun_xye_function_form.m')
            %
            %   x_arg = 'x1,x2,x3'
            %   x_descr = 'x1,x2,x3    Arrays of x values along first, second and third dimensions'
            %
            % <#doc_beg:> multifit
            %   <#file:> <set_fun_intro>
            %   <#file:> <set_fun_xye_function_form> <x_arg> <x_descr>
            %
            %     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>
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
            %     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>

            % <#doc_def:>
            %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
            %   set_bfun_intro = fullfile(mfclass_doc,'set_bfun_intro.m')
            %   set_fun_xye_function_form = fullfile(mfclass_doc,'set_fun_xye_function_form.m')
            %
            %   x_arg = 'x1,x2,x3'
            %   x_descr = 'x1,x2,x3    Arrays of x values along first, second and third dimensions'
            %
            % <#doc_beg:> multifit
            %   <#file:> <set_bfun_intro>
            %   <#file:> <set_fun_xye_function_form> <x_arg> <x_descr>
            %
            %     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>
            % <#doc_end:>

            try
                obj = set_bfun@mfclass (obj, varargin{:});
            catch ME
                error(ME.message)
            end
        end

    end
end
