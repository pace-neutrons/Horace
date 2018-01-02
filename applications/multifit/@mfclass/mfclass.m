classdef mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    %
    % mfclass Methods:
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
    %
    % mfclass Properties:
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
    %   class_name = 'mfclass'
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
    
    
    % Original author: T.G.Perring
    %
    % $Revision: 668 $ ($Date: 2017-12-13 11:00:34 +0000 (Wed, 13 Dec 2017) $)
    
    
    % Notes on inheriting mfclass for use by particular classes:
    % - Alter the functionality of methods and/or add methods by inheriting
    %   mfclass e.g. mfclass_sqw
    % - Wrap the fit functions and/or provide initialisation functions by
    %   creating an object of class mfclass_wrapfun
    % - Create methods for the class that call the constructors mfclass_wrapfun,
    %   mfclass_sqw.
    % This procedure is required because we will generally want the method
    % multifit2 for objects of class sqw, d1d, d2d,... for example, and
    % multifit2 will generally need to operate differently for each class.
    
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties
        
        % ---------------------------------------------------------------------
        % Data properties
        % ---------------------------------------------------------------------
        % Data class: if empty, then no restriction, else name of class of data
        dataset_class_ = '';
        
        % Cell array (row) with input data as provided by user (i.e. elements
        % may be cell arrays of {x,y,e}, structure arrays, object arrays);
        % a special case is thee elements x, y, e.
        % If an element is an array it can be entered with any shape, but if
        % a dataset is removed from the array, then it will turned into a column
        % or a row vector (depending on its initial shape, according to usual
        % matlab reshaping rules for logically indexed arrays)
        data_ = {};
        
        % Cell array of datasets (row) that contain repackaged data: every entry
        % is either
        %	- an x-y-e triple with wout{i}.x a cell array of arrays, one for
        %     each x-coordinate,
        %   - a scalar object
        w_ = {};
        
        % Mask arrays: cell array of logical arrays (1 for retain, 0 for ignore)
        % The size of each mask array matches the size of the y array in the
        % corresponding data set
        msk_ = {};
        
        % ---------------------------------------------------------------------
        % Function properties
        % ---------------------------------------------------------------------
        % Local or global foreground functions
        foreground_is_local_ = false;
        
        % Local or global background functions
        background_is_local_ = true;
        
        % Cell array of foreground function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. If no datasets, no handle(s).
        % Missing functions are set to [].
        fun_ = cell(1,0);
        
        % Array of type mfclass_plist with the starting foreground function parameters (row vector).
        % It has the same number of elements as fun_
        % If a function is missing the corresponding element of pin_ is mfclass_plist().
        pin_ = repmat(mfclass_plist(),1,0);
        
        % Row vector of the number of numeric parameters for each foreground function.
        % If a function is empty, then corresponding element of np_ is 0
        np_ = zeros(1,0);
        
        % Cell array (row) of logical row vectors, one for each foreground function.
        % It has the same number of elements as fun_
        % If a function is missing the corresponding element of free is true(1,0)
        free_ = cell(1,0);
        
        % Cell array of background function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. If no datasets, no handle(s).
        % Missing functions are set to [].
        bfun_ = cell(1,0);
        
        % Array of type mfclass_plist with the starting background function parameters (row vector).
        % It has the same number of elements as bfun_
        % If a function is missing the corresponding element of bpin_ is mfclass_plist().
        bpin_ = repmat(mfclass_plist(),1,0);
        
        % Row vector of the number of numeric parameters for each background function.
        % It has the same number of elements as bfun_
        % If a function is empty, then corresponding element nf nbp_ is 0
        nbp_ = zeros(1,0);
        
        % Cell array (row) of logical row vectors, one for each background function.
        % It has the same number of elements as bfun_
        % If a function is missing the corresponding element of bfree is true(1,0)
        bfree_ = cell(1,0);
        
        % ---------------------------------------------------------------------
        % Parameter constraints properties
        % ---------------------------------------------------------------------
        % Column vector length (nptot_ + nbptot_)
        % =false if parameter is unbound, =true if bound
        bound_ = false(0,1);
        
        % Column vector length (nptot_ + nbptot_)
        % =0 if parameter is unbound; ~=0 index of parameter to
        % which the parameter is bound (in range 1 to (nptot_ + nbptot_))
        bound_to_ = zeros(0,1);
        
        % Column vector length (nptot_ + nbptot_) with ratio of
        % bound parameter to fixed parameter; =0 if a parameter is unbound;
        % and = NaN if ratio is to be determined by initial parameter values
        ratio_ = zeros(0,1);
        
        % Column vector of parameters to which each parameter is bound, resolved
        % to account for a chain of bindings
        bound_to_res_ = zeros(0,1);
        
        % Column vector of binding ratios resolved to account for a chain
        % of bindings
        ratio_res_ = zeros(0,1);
        
        % ---------------------------------------------------------------------
        % Function wrap properties
        % ---------------------------------------------------------------------
        wrapfun_ = mfclass_wrapfun();
        
        % ---------------------------------------------------------------------
        % Output control properties
        % ---------------------------------------------------------------------
        % Options structure.
        % Fields are:
        %   listing                 Level at which messages are output: 0,1,2
        %   fit_control_parameters  [rel_step, max_iter, tol_chisqr]
        %   selected                Simulate only on fittable data in selected
        %                          unmasked region
        %   squeeze_xye             Remove points from simulation of x-y-e
        %                          data where data is masked or not fittable
        options_ = struct([]);
        
    end
    
    properties (Dependent, Access=private)
        ndatatot_       % Total number of datasets (==numel(w_))
    end
    
    properties (Dependent, Access=protected)
        % Properties that are exposed to child classes (i.e. subclasses)
        
        dataset_class   % data class
        pin_obj         % pin returned as array of mfclass_plist objects
        np              % number of parameters in each foreground function
        bpin_obj        % bpin returned as array of mfclass_plist objects
        nbp             % number of parameters in each background function
        wrapfun         % function wrapping object
    end
    
    properties (Dependent)
        % Public properties - they all work by going via private properties
        
        % Dataset or cell array of datasets (row vector)
        % Has the form:
        %
        %   w1    or     {w1,w2,...}
        %
        % In the case when the data sets are in the form of objects of a
        % class, then w1,w2,... are objects or arrays of objects.
        %
        % In the case when x-y-e data is being fitted then w1,w2,... are
        %   - Cell array of arrays x, y, e above (defines a single dataset):
        %       w = {x,y,e}
        %
        %     Cell array of cell arrays that defines multiple datasets:
        %       w = {{x1,y1,e1}, {x2,y2,e2}, {x3,y3,e3},...}
        %
        %   - Structure with fields w.x, w.y, w.e  where x, y, e have one of the
        %     forms described above (this defines a single dataset)
        %
        %     Structure array with fields w(i).x, w(i).y, w(i).e (this defines
        %     several datasets)
        %
        % For details of the form of the arrays x,y,e, see the help to the
        % method set_data
        data
        
        % Mask array (single data set) or cell array containing mask arrays
        % One mask array per data sets (row vector). Each mask array has the
        % same size as the signal array for the corresponding data set.
        mask
        
        % Foreground is local if true, or global if false
        local_foreground
        
        % Foreground is global if true, or local if false
        global_foreground
        
        % Foreground function handle or cell array of function handles (row vector)
        % If the foreground fit function is global, fun is a single function handle
        % If the foreground fit function(s) are local there is one function handle
        % per dataset. If a function is not given for a dataset, the corresponding
        % handle is set to [].
        %
        % See also set_fun
        fun
        
        % Foreground parameter list (single function) or cell array of parameter lists
        % The form of the parameter list depends on the fit function, and the help
        % for set_fun should be consulted (link below). In most cases, the parameter
        % list for a fit function is either:
        %
        %   - A numeric vector (row or column)
        %       e.g.    p = [10,100,0.01]
        %
        %   - A cell array (row) of arguments, the first of which is a numerica vector
        %    of parameers that can be refined in the fit, followed by further arguments
        %    needed by the function, for example the name of a lookup file or a logical
        %    flag to determine the choice of a branch in the function
        %       e.g.    p = {[10,100,0.01], 'my_table.txt', 'false'}
        %
        % See also set_fun set_pin
        pin
        
        % Defines which foreground function parameters are free to vary in fit
        % If there is one fit function, then the property is a logical row vector
        % (or row of 1 and 0) with true for parameters that will vary and false (0) for
        % those that are fixed. If there is more than one fit function, that is, there
        % is more than one dataset and the fit is local not global, then the property
        % is a cell array of logical row vectors.
        %
        % See also set_fun set_pin set_free
        free
        
        % Array describing binding of foreground parameters
        % Array size [n,5] where n is the number of distinct bindings of foreground
        % parameters. Each row consists of
        %       ip_bound, ifun_bound, ip_free, ifun_free, ratio
        % where
        %   ip_bound    Index of bound parameter in the list for the function ifun_bound (below)
        %   ifun_bound  Index of function
        %               - foreground functions: numbered 1,2,3,...numel(fun)
        %               - background functions: numbered -1,-2,-3,...-numel(bfun)
        %   p_free      Index of the free parameter in the list for the function
        %              ifun_free (below) to which the bound parameter is tied
        %   ifun_free   Index of the function
        %   ratio       Ratio of the bound parameter value to free parameter value
        %
        % The bindings have been resolved to account for any chain of binding to
        % the floating parameter at the end of the chain.
        %
        % See also set_fun set_bind
        bind
        
        % Background is local if true, or global if false
        local_background
        
        % Background is global if true, or local if false
        global_background
        
        % Background function handle or cell array of function handles (row vector)
        % If the background fit function is global, fun is a single function handle
        % If the background fit function(s) are local there is one function handle
        % per dataset. If a function is not given for a dataset, the corresponding
        % handle is set to [].
        %
        % See also set_bfun
        bfun
        
        % Background parameter list (single function) or cell array of parameter lists
        % The form of the parameter list depends on the fit function, and the help
        % for set_fun should be consulted (link below). In most cases, the parameter
        % list for a fit function is either:
        %
        %   - A numeric vector (row or column)
        %       e.g.    p = [10,100,0.01]
        %
        %   - A cell array (row) of arguments, the first of which is a numerica vector
        %    of parameers that can be refined in the fit, followed by further arguments
        %    needed by the function, for example the name of a lookup file or a logical
        %    flag to determine the choice of a branch in the function
        %       e.g.    p = {[10,100,0.01], 'my_table.txt', 'false'}
        %
        % See also set_bfun set_bpin
        bpin
        
        % Defines which foreground function parameters are free to vary in fit
        % If there is one fit function, then the property is a logical row vector
        % (or row of 1 and 0) with true for parameters that will vary and false (0) for
        % those that are fixed. If there is more than one fit function, that is, there
        % is more than one dataset and the fit is local not global, then the property
        % is a cell array of logical row vectors.
        %
        % See also set_bfun set_bpin set_bfree
        bfree
        
        % Array describing binding of background parameters
        % Array size [n,5] where n is the number of distinct bindings of foreground
        % parameters. Each row consists of
        %       ip_bound, ifun_bound, ip_free, ifun_free, ratio
        % where
        %   ip_bound    Index of bound parameter in the list for the function ifun_bound (below)
        %   ifun_bound  Index of function
        %               - foreground functions: numbered 1,2,3,...numel(fun)
        %               - background functions: numbered -1,-2,-3,...-numel(bfun)
        %   p_free      Index of the free parameter in the list for the function
        %              ifun_free (below) to which the bound parameter is tied
        %   ifun_free   Index of the function
        %   ratio       Ratio of the bound parameter value to free parameter value
        %
        % The bindings have been resolved to account for any chain of binding to
        % the floating parameter at the end of the chain.
        %
        % See also set_bfun set_bbind
        bbind
        
        % Options structure
        % Fields are:
        %   listing                 Level at which messages are output: 0,1,2
        %   fit_control_parameters  [rel_step, max_iter, tol_chisqr]
        %   selected                Simulate only on fittable data in selected
        %                          unmasked region
        %   squeeze_xye             Remove points from simulation of x-y-e
        %                          data where data is masked or not fittable
        options
        
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass(varargin)
            % Create fitting object
            %
            %   >> myObj = mfclass              % empty fitting object
            %   >> myObj = mfclass (w1,w2,...)  % datsets w1, w2, ...
            %   >> myObj = mfclass (...dataset_class)   % data class e.g. 'sqw'
            %   >> myObj = mfclass (...wrapfun)         % define function wrapping
            %
            % Input:
            % -----
            % OPtional data arguments (must all appear first):
            %   w1, w2, ...     Datasets or arrays of datasets
            %
            % Trailing optional arguments (can appear in any order):
            %   dataset_class   Character string giving class name of datasets
            %                  so that the datatype is explicitly checked
            %   wrapfun         Function wrapper object: defines the nesting of
            %                  of the fit functions to permit mor complex function
            %                  calls, and also if caller information is passed to
            %                  the fitting function
            %
            % See also set_data mfclass_wrapfun
            try
                [ok,mess,nopt,ind_dataset_class,ind_wrapfun] = strip_trailing_opts;
                if ok
                    obj = set_data(obj,varargin{1:end-nopt});
                    if ~isempty(ind_dataset_class)
                        obj.dataset_class_ = varargin{ind_dataset_class};
                    end
                    if ~isempty(ind_wrapfun)
                        obj.wrapfun_ = varargin{ind_wrapfun};
                    end
                else
                    error(mess)
                end
                obj = set_options(obj,'-default');
            catch ME
                error(ME.message)
            end
            %--------------------------------------------------------------------------------------
            function [ok,mess,nopt,ind_dataset_class,ind_wrapfun] = strip_trailing_opts
                % Allow one or both of dataset_class and wrapfun at the tail of an argument list
                
                ok = true; mess = ''; nopt = 0; ind_dataset_class=[]; ind_wrapfun = [];
                is_wrapfun = @(x)isa(x,'mfclass_wrapfun');
                is_dataset_class = @(x)(isa(x,'char') && is_string(x) && ~isempty(x));
                
                narg = numel(varargin);
                if narg>=1
                    if is_wrapfun(varargin{end})
                        nopt=1; ind_wrapfun = narg;
                    elseif is_dataset_class(varargin{end})
                        nopt=1; ind_dataset_class = narg;
                    else
                        return
                    end
                end
                
                if narg>=2
                    if is_wrapfun(varargin{end-1})
                        if isempty(ind_wrapfun)
                            nopt=2; ind_wrapfun = narg-1;
                        else
                            ok=false; mess='Optional function wrapper given twice';
                        end
                    elseif is_dataset_class(varargin{end-1})
                        if isempty(ind_dataset_class)
                            nopt=2; ind_dataset_class = narg-1;
                        else
                            ok=false; mess='Optional dataset class name given twice';
                        end
                    else
                        return
                    end
                end
            end
            %--------------------------------------------------------------------------------------
        end
        
        %------------------------------------------------------------------
        % Set/get methods: private dependent properties
        %------------------------------------------------------------------
        % Get methods
        function out = get.ndatatot_(obj)
            out = numel(obj.w_);
        end
        
        %------------------------------------------------------------------
        % Set/get methods: protected dependent properties
        %------------------------------------------------------------------
        % These are properties that need to be settable or gettable from
        % sub-classes.
        
        %------------------------------------------------------------------
        % Set methods
        function obj = set.wrapfun(obj, val)
            if isa(val,'mfclass_wrapfun') && isscalar(val)
                obj.wrapfun_ = val;
            else
                error('Wrapper object must be of class ''mfclass_wrapfun''')
            end
        end
        
        %------------------------------------------------------------------
        % Get methods
        function out = get.dataset_class(obj)
            out = obj.dataset_class_;
        end
        
        function out = get.pin_obj(obj)
            out = obj.pin_;
        end
        
        function out = get.np(obj)
            out = obj.np_;
        end
        
        function out = get.bpin_obj(obj)
            out = obj.bpin_;
        end
        
        function out = get.nbp(obj)
            out = obj.nbp_;
        end
        
        function out = get.wrapfun(obj)
            out = obj.wrapfun_;
        end
        
        
        %------------------------------------------------------------------
        % Set/get methods: public dependent properties
        %------------------------------------------------------------------
        % Set methods
        function obj = set.local_foreground(obj, val)
            if ~islognumscalar(val), error('local_foreground must be a logical scalar'), end
            isfore = true;
            obj = set_scope_private_ (obj, isfore, val);
        end
        
        function obj = set.local_background(obj,val)
            if ~islognumscalar(val), error('local_background must be a logical scalar'), end
            isfore = false;
            obj = set_scope_private_ (obj, isfore, val);
        end
        
        function obj = set.global_foreground(obj,val)
            if ~islognumscalar(val), error('global_foreground must be a logical scalar'), end
            isfore = true;
            obj = set_scope_private_ (obj, isfore, ~val);
        end
        
        function obj = set.global_background(obj,val)
            if ~islognumscalar(val), error('global_background must be a logical scalar'), end
            isfore = false;
            obj = set_scope_private_ (obj, isfore, ~val);
        end
        
        %------------------------------------------------------------------
        % Get methods
        function out = get.data(obj)
            if numel(obj.data_)==1
                out = obj.data_{1};     % cell array of length unity, so return actual data
            else
                out = obj.data_;
            end
        end
        
        function out = get.mask(obj)
            if numel(obj.msk_)==1
                out = obj.msk_{1};      % cell array of length unity, so return actual mask
            else
                out = obj.msk_;
            end
        end
        
        function out = get.local_foreground(obj)
            out = obj.foreground_is_local_;
        end
        
        function out = get.local_background(obj)
            out = obj.background_is_local_;
        end
        
        function out = get.global_foreground(obj)
            out = ~(obj.foreground_is_local_);
        end
        
        function out = get.global_background(obj)
            out = ~(obj.background_is_local_);
        end
        
        function out = get.fun(obj)
            if isscalar(obj.fun_)
                out = obj.fun_{1};
            else
                out = obj.fun_;
            end
        end
        
        function out = get.pin(obj)
            if isscalar(obj.pin_)
                out = obj.pin_.plist;
            else
                out = arrayfun(@(x)x.plist,obj.pin_,'UniformOutput',false);
            end
        end
        
        function out = get.free(obj)
            if isscalar(obj.free_)
                out = obj.free_{1};
            else
                out = obj.free_;
            end
        end
        
        function out = get.bind (obj)
            nptot = sum(obj.np_);
            bnd = obj.bound_(1:nptot);
            % Parameter and function indicies of bound parameters
            [ipb, ifunb] = ind2parfun (find(bnd), obj.np_, obj.nbp_);
            % Parameter and function indicies of bound-to parameters
            indf = obj.bound_to_res_(1:nptot);
            [ipf, ifunf] = ind2parfun (indf(bnd), obj.np_, obj.nbp_);
            % Binding ratios
            R = obj.ratio_res_(1:nptot);
            R = R(bnd);
            % Output array
            out = [ipb,ifunb,ipf,ifunf,R];
        end
        
        function out = get.bfun(obj)
            if isscalar(obj.bfun_)
                out = obj.bfun_{1};
            else
                out = obj.bfun_;
            end
        end
        
        function out = get.bpin(obj)
            if isscalar(obj.bpin_)
                out = obj.bpin_.plist;
            else
                out = arrayfun(@(x)x.plist,obj.bpin_,'UniformOutput',false);
            end
        end
        
        function out = get.bfree(obj)
            if isscalar(obj.bfree_)
                out = obj.bfree_{1};
            else
                out = obj.bfree_;
            end
        end
        
        function out = get.bbind (obj)
            nptot = sum(obj.np_);
            nbptot = sum(obj.nbp_);
            range = nptot+1:nptot+nbptot;
            bnd = obj.bound_(range);
            % Parameter and function indicies of bound parameters
            [ipb, ifunb] = ind2parfun (nptot+find(bnd), obj.np_, obj.nbp_);
            % Parameter and function indicies of bound-to parameters
            indf = obj.bound_to_res_(range);
            [ipf, ifunf] = ind2parfun (indf(bnd), obj.np_, obj.nbp_);
            % Binding ratios
            R = obj.ratio_res_(range);
            R = R(bnd);
            % Output array
            out = [ipb,-ifunb,ipf,-ifunf,R];
        end
        
        function out = get.options(obj)
            out = obj.options_;
        end
        
    end
    
    methods (Access=private)
        %------------------------------------------------------------------
        % Methods in the defining folder but which need to be kept private
        %------------------------------------------------------------------
        obj = set_fun_props_ (obj, S)
        obj = set_constraints_props_ (obj, S)
        
        S = get_fun_props_ (obj)
        S = get_constraints_props_ (obj)
        
        obj = set_scope_private_(obj, isfore, set_local)
        
        [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_fun_private_ (obj, isfore, ifun)
        
        [ok, mess, obj] = set_pin_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_pin_private_ (obj, isfore, args)
        
        [ok, mess, obj] = set_free_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_free_private_ (obj, isfore, args)
        
        [ok, mess, obj] = add_bind_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_bind_private_ (obj, isfore, ifun)
        
        [ok_sim, ok_fit, mess, pf, p_info] = ptrans_initialise_ (obj)
        
    end
    
    methods (Static)
        %------------------------------------------------------------------
        % Methods to interface to legacy (i.e. pre-2018) multifit
        %------------------------------------------------------------------
        function status = legacy(varargin)
            % Determine if the arguments are for legacy operation of multifit
            %
            %   >> is_legacy = mfclass.legacy(arg2, arg2,...)
            %
            % If the argument list contains a function handle this is
            % incompatible with the new operation of multifit and so the
            % only possibility is a legacy call.
            
            if numel(varargin)==0
                status = false;     % no arguments is valid, and only valid, for new multifit
            else
                fhandle = cellfun(@fhandle_arg,varargin);
                status = any(fhandle);
            end
            %--------------------------------------------------------------
            function status = fhandle_arg(arg)
                % Determine if argument is a function handle or cell array
                % of function handles
                if iscell(arg)
                    status = all(cellfun(@(x)(isa(x,'function_handle')),arg));
                else
                    status = isa(arg,'function_handle');
                end
            end
            %--------------------------------------------------------------
        end
        
        function varargout = legacy_call (mf_handle, varargin)
            % Make call to legacy multifit function or method. Use as:
            %
            %   >> [varargout{1:nargout}] = mfclass.legacy_call (mf_handle, arg1, arg2,...)
            %
            % Input:
            % ------
            %   mf_handle       Handle to the legacy multifit function
            %   arg1, arg2,...  All arguments to pass to legacy function (including data)

            try
                [varargout{1:nargout}] = mf_handle (varargin{:});
            catch ME
                throwAsCaller(MException('legacy_call:failure', '%s', ME.message));
            end
        end
    end
    
end
