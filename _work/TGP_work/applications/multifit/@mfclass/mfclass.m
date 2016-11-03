classdef mfclass
% Simultaneously fit functions to several datasets, with optional
% background functions. The foreground function(s) and background
% function(s) can be set to apply globally to all datasets, or locally,
% one function per dataset.
%
% mfclass Methods:
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
% To set fitting functions
%   set_fun      - Set foreground fit functions
%   clear_fun    - Clear one or more foreground fit functions
%   set_bfun     - Set background fit functions
%   clear_bfun   - Clear one or more background fit functions
%
% To set which parameters are fixed or free:
%   set_free     - Set free or fix parameters
%   clear_free   - Clear all parameters to be free for one or more data sets
%   set_bfree    - Set free or fix parameters
%   clear_bfree  - Clear all parameters to be free for one or more data sets
%
% To bind parameters:
%   set_bind     - Bind foreground parameter values in fixed ratios
%   add_bind     - Add further bindings
%   clear_bind   - Clear parameter bindings for one or more foreground functions
%   set_bbind    - Bind foreground parameter values in fixed ratios
%   add_bbind    - Add further bindings
%   clear_bbind  - Clear parameter bindings for one or more foreground functions

    % <#doc_def:>
    %   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
    %   mfclass_purpose_summary_file = fullfile(mfclass_doc,'purpose_summary.m')
    %   mfclass_methods_summary_file = fullfile(mfclass_doc,'methods_summary.m')
    %
    %   class_name = 'mfclass'
    %
    % <#doc_beg:>
    %   <#file:> <mfclass_purpose_summary_file>
    %
    % <class_name> Methods:
    %   <#file:> <mfclass_methods_summary_file>
    % <#doc_end:>

    properties (Access=protected, Hidden=true)
        % --------------------------------
        % Data class and function wrapping
        % --------------------------------
        % mfclass_wrapfun object
        wrapfun_ = [];
    end

    properties (Access=private, Hidden=true)
        % Stored properties - but kept private and accessible only through
        % public dependent properties
        %
        % ---------------
        % Data properties
        % ---------------
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

        %         % Cell array of masked datasets (row): every entry is either
        %         %	- an x-y-e triple with wout{i}.x a cell array of arrays, one for
        %         %     each x-coordinate,
        %         %   - a scalar object
        %         wmask_ = {};

        % -------------------
        % Function properties
        % -------------------
        foreground_is_local_ = false;

        % Cell array of foreground function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. If no datasets, no handle(s).
        % Missing functions are set to [].
        fun_ = cell(1,0);

        % Cell array of the starting foreground function parameters (row vector).
        % If a function is missing the corresponding element of pin_ is [].
        pin_ = cell(1,0);

        % Row vector of the number of numeric parameters for each foreground function.
        % If a function is empty, then corresponding element of np_ is 0
        np_ = zeros(1,0);

        background_is_local_ = true;

        % Cell array of background function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. If no datasets, no handle(s).
        % Missing functions are set to [].
        bfun_ = cell(1,0);

        % Cell array of the starting background function parameters (row vector).
        % If a function is missing the corresponding element of bpin_ is [].
        bpin_ = cell(1,0);

        % Row vector of the number of numeric parameters for each background function.
        % If a function is empty, then corresponding element nf nbp_ is 0
        nbp_ = zeros(1,0);

        % --------------------------------
        % Parameter constraints properties
        % --------------------------------
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

        % -------------------------
        % Output control properties
        % -------------------------
        % Options structure. Fields are:
        %   listing                 Level at which messages are output: 0,1,2
        %   fit_control_parameters  [rel_step, max_iter, tol_chisqr]
        %   selected                Simulate only on fittable data in selected
        %                          region
        %   squeeze_xye             Remove points from simulation of x-y-e
        %                          data where data is masked or not fittable
        options_ = struct([]);

    end

    properties (Dependent)
        % Cell array containing the input data (row vector)
        data
        w           % *** get rid of for release
        msk         % *** get rid of for release
        wmask       % *** get rid of for release

        % Foreground is local if true or global if false (default)
        local_foreground
        % Foreground is global if true (default) or local if false
        global_foreground
        % Cell array of foreground function handles (row vector)
        % If the foreground fit function is global, the cell array contains just
        % one handle. If the foreground fit functions are local the array contains
        % one handle per dataset. If a function is not given for a dataset, the
        % corresponding handle is set to [].
        fun
        % Cell array of foreground function parameters (row vector)
        %  the function parameters have the general form
        pin
        pfree
        pbind
        pbind_dbg   % *** get rid of for release

        % Background is local if true (default) or global if false
        local_background
        % Background is global if true or local if false (default)
        global_background
        % Cell array (row) of background function handles
        bfun
        bpin
        bpfree
        bpbind
        bpbind_dbg  % *** get rid of for release

        options
    end

    properties (Dependent, Access=protected)
        ndatatot
        np
        nbp
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass(varargin)
            % Interpret input arguments as solely data
            try
                if numel(varargin)>0 && isa(varargin{1},'mfclass_wrapfun')
                    obj.wrapfun_ = varargin{1};
                    obj = set_data(obj,varargin{2:end});
                else
                    obj.wrapfun_ = mfclass_wrapfun;
                    obj = set_data(obj,varargin{:});
                end
                obj = set_option(obj,'-default');
            catch ME
                error(ME.message)
            end
        end

        %------------------------------------------------------------------
        % Set/get methods: dependent properties
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
            out = obj.data_;
        end

        function out = get.w(obj)
            out = obj.w_;
        end

        function out = get.msk(obj)   % *** get rid of for release
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
            out = obj.pin_;
        end

        function out = get.pfree(obj)
            nptot = sum(obj.np_);
            out = mat2cell(obj.free_(1:nptot)',1,obj.np_);
        end

        function out = get.pbind (obj)
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

        function out = get.pbind_dbg(obj)   % *** get rid of for release
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
            out = obj.bpin_;
        end

        function out = get.bpfree(obj)
            nptot = sum(obj.np_);
            nbptot = sum(obj.nbp_);
            range = nptot+1:nptot+nbptot;
            out = mat2cell(obj.free_(range)',1,obj.nbp_);
        end

        function out = get.bpbind (obj)
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

        function out = get.bpbind_dbg(obj)   % *** get rid of for release
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
        function out = get.ndatatot(obj)
            out = obj.ndatatot_;
        end

        function out = get.np(obj)
            out = obj.np_;
        end

        function out = get.nbp(obj)
            out = obj.np_;
        end

    end

    methods (Access=private)
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

        [fun, p, bfun, bp] = get_wrapped_functions_ (obj,...
            func_init_output_args, bfunc_init_output_args)
    end

end
