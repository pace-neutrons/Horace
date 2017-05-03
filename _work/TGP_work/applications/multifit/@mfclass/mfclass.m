classdef mfclass
    % Simultaneously fit functions to several datasets, with optional
    % background functions. The foreground function(s) and background
    % function(s) can be set to apply globally to all datasets, or locally,
    % one function per dataset.
    %
    % mfclass Methods:
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
    %   class_name = 'mfclass'
    %
    % <#doc_beg:> multifit
    %   <#file:> <mfclass_purpose_summary_file>
    %
    % <class_name> Methods:
    %
    %   <#file:> <mfclass_methods_summary_file>
    % <#doc_end:>


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
        % Data class
        dataset_class_ = '';

        % Cell array (row) with input data as provided by user (i.e. elements
        % may be cell arrays of {x,y,e}, structure arrays, object arrays);
        % a special case is thee elements x, y, e.
        % If an element is an array it can be entered with any shape, but if
        % a dataset is removed from the array, then it will turned into a column
        % or a row vector (depending on its initial shape, according to usual
        % matlab reshaping rules for logically indexed arrays)
        data_ = {};

        % Cell array (row) of numeric arrays with the number of dimensions of each
        % dataset; one array for each entry in data_
        ndim_ = {};

        % Row vector with number of datasets in each entry in data_
        ndata_ = [];

        % Total number of datasets (==sum(ndata_))
        ndatatot_ = 0;

        % Column vector with index of entry in data_ for each dataset
        item_ = zeros(0,1);

        % Column vector with index within the entry in data_ for each dataset
        ix_ = zeros(0,1);

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
        foreground_is_local_ = false;

        % Cell array of foreground function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. If no datasets, no handle(s).
        % Missing functions are set to [].
        fun_ = cell(1,0);

        % Array of type mfclass_plist with the starting foreground function parameters (row vector).
        % If a function is missing the corresponding element of pin_ is mfclass_plist().
        pin_ = repmat(mfclass_plist(),1,0);

        % Row vector of the number of numeric parameters for each foreground function.
        % If a function is empty, then corresponding element of np_ is 0
        np_ = zeros(1,0);

        background_is_local_ = true;

        % Cell array of background function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. If no datasets, no handle(s).
        % Missing functions are set to [].
        bfun_ = cell(1,0);

        % Array of type mfclass_plist with the starting background function parameters (row vector).
        % If a function is missing the corresponding element of bpin_ is mfclass_plist().
        bpin_ = repmat(mfclass_plist(),1,0);

        % Row vector of the number of numeric parameters for each background function.
        % If a function is empty, then corresponding element nf nbp_ is 0
        nbp_ = zeros(1,0);

        % ---------------------------------------------------------------------
        % Parameter constraints properties
        % ---------------------------------------------------------------------
        % Logical column vector length (nptot_ + nbptot_)
        % =true if parameter is free, =false if fixed.
        % This contains what was set, but needs to be resolved to find the
        % independent floating parameters
        free_ = true(0,1);

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

    properties (Dependent)
        % Public properties - they all work by going via private properties

        % Data set object or cell array of data set objects (row vector)
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
        % one mask array per data sets (row vector). Each mask array has the
        % same size as the signal array for the corresponding data set.
        mask

        w           % *** get rid of for release
        msk         % *** get rid of for release
        wmask       % *** get rid of for release

        % Foreground is local if true, or global if false
        local_foreground

        % Foreground is global if true, or local if false
        global_foreground

        % Cell array of foreground function handles (row vector)
        % If the foreground fit function is global, the cell array contains just
        % one handle. If the foreground fit functions are local the array contains
        % one handle per dataset. If a function is not given for a dataset, the
        % corresponding handle is set to [].
        fun

        % Foreground function parameters
        % Foreground function parameter list (single function) or cell array of foreground
        % functions parameters (more than one function)(row vector)
        %
        % The form of a parameter list is
        pin     % cell array of pin(1).plist, so can be fed into set_fun
        free
        bind

        bind_dbg   % *** get rid of for release

        % Background is local if true, or global if false
        local_background

        % Background is global if true, or local if false
        global_background

        % Cell array of background function handles (row vector)
        % If the background fit function is global, the cell array contains just
        % one handle. If the background fit functions are local the array contains
        % one handle per dataset. If a function is not given for a dataset, the
        % corresponding handle is set to [].
        bfun
        bpin    % cell array of bpin(1).plist, so can be fed into set_fun
        bfree
        bbind

        bbind_dbg  % *** get rid of for release

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

    properties (Dependent, Access=protected)
        % Properties that are exposed to child classes (i.e. subclasses)

        dataset_class   % data class
        ndatatot        % total number of datasets
        pin_obj         % pin returned as array of mfclass_plist objects
        np              % number of parameters in each foreground function
        bpin_obj        % bpin returned as array of mfclass_plist objects
        nbp             % number of parameters in each background function
        wrapfun         % function wrapping object
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
        % Set/get methods: public dependent properties
        %------------------------------------------------------------------
        % Set methods
        function obj = set.local_foreground(obj, val)
            if ~islognumscalar(val), error('local_foreground must be a logical scalar'), end
            isfore = true;
            obj = function_set_scope_ (obj, isfore, val);
        end

        function obj = set.local_background(obj,val)
            if ~islognumscalar(val), error('local_background must be a logical scalar'), end
            isfore = false;
            obj = function_set_scope_ (obj, isfore, val);
        end

        function obj = set.global_foreground(obj,val)
            if ~islognumscalar(val), error('global_foreground must be a logical scalar'), end
            isfore = true;
            obj = function_set_scope_ (obj, isfore, val);
        end

        function obj = set.global_background(obj,val)
            if ~islognumscalar(val), error('global_background must be a logical scalar'), end
            isfore = false;
            obj = function_set_scope_ (obj, isfore, val);
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

        %------------------
        function out = get.w(obj)       % *** get rid of for release
            out = obj.w_;
        end

        function out = get.msk(obj)     % *** get rid of for release
            out = obj.msk_;
        end

        function out = get.wmask(obj)   % *** get rid of for release
            if ~isempty(obj.w_)
                [out,~,ok,mess] = mask_data_for_fit (obj.w_,obj.msk_);
                if ok && ~isempty(mess)
                    display_message(mess);
                elseif ~ok
                    error_message(mess);
                end
            else
                out = obj.w_;
            end
        end
        %------------------

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
            out = obj.fun_;
        end

        function out = get.pin(obj)
            out = arrayfun(@(x)x.plist,obj.pin_,'UniformOutput',false);
        end

        function out = get.free(obj)
            nptot = sum(obj.np_);
            out = mat2cell(obj.free_(1:nptot)',1,obj.np_);
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

        function out = get.bind_dbg(obj)   % *** get rid of for release
            % *** Need to extract in different form for production version
            nptot = sum(obj.np_);
            out = [double(obj.free_(1:nptot))';...
                double(obj.bound_(1:nptot))';...
                obj.bound_to_(1:nptot)';...
                obj.ratio_(1:nptot,:)';
                obj.bound_to_res_(1:nptot)';...
                obj.ratio_res_(1:nptot,:)'];
        end

        function out = get.bfun(obj)
            out = obj.bfun_;
        end

        function out = get.bpin(obj)
            out = arrayfun(@(x)x.plist,obj.bpin_,'UniformOutput',false);
        end

        function out = get.bfree(obj)
            nptot = sum(obj.np_);
            nbptot = sum(obj.nbp_);
            range = nptot+1:nptot+nbptot;
            out = mat2cell(obj.free_(range)',1,obj.nbp_);
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

        function out = get.bbind_dbg(obj)   % *** get rid of for release
            % *** Need to extract in different form for production version
            nptot = sum(obj.np_);
            nbptot = sum(obj.nbp_);
            range = nptot+1:nptot+nbptot;
            out = [double(obj.free_(range))';...
                double(obj.bound_(range))';...
                obj.bound_to_(range)';...
                obj.ratio_(range,:)';
                obj.bound_to_res_(range)';...
                obj.ratio_res_(range,:)'];
        end

        function out = get.options(obj)
            out = obj.options_;
        end

        %------------------------------------------------------------------
    end

    methods
        %------------------------------------------------------------------
        % Set/get methods: hidden dependent properties
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

        function out = get.ndatatot(obj)
            out = obj.ndatatot_;
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
            out = obj.np_;
        end

        function out = get.wrapfun(obj)
            out = obj.wrapfun_;
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

        obj = function_set_scope_(obj, isfore, set_local)

        [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_fun_private_ (obj, isfore, ifun)

        [ok, mess, obj] = set_free_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_free_private_ (obj, isfore, args)

        [ok, mess, obj] = add_bind_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_bind_private_ (obj, isfore, ifun)

        [ok_sim, ok_fit, mess, pf, p_info] = ptrans_initialise_ (obj)

    end

end
