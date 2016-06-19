classdef mfclass
    % MF Multifit object
    %
    % Multifit is used to simultaneously fit a function to several datasets, with
    % optional background functions.
    %
    % The data to be fitted can be a set or sets of of x,y,e arrays, or an
    % object or array of objects of a class. [Note: if you have written your own
    % class, there are some required methods for this fit function to work.
    % See notes at the end of this help]
    %
    % Syntax:
    %   >> mf = multifit                   % Creates empty multifit object
    %
    % For datasets which are arbitrary classes, multifit requires the following methods:
    %   sigvar_get   - returns the signal, variance and empty mask of the data
    %                  See IX_dataset_1D/sigvar.m for an example.
    %   mask         - applies a mask to an input dataset, returning the masked set
    %                  See IX_dataset_1D/mask.m for an example.
    % and either:
    %   mask_points  - returns a mask for a dataset like the mask_points_xye() function
    %                  See sqw/mask_points.m for an example
    % or
    %   sigvar_getx  - returns the ordinate(s) [bin-centres] of the dataset
    %                  See IX_dataset_1D/sigvar_getx.m for an example.
    % In addition, all fit functions must be class methods, or a wrapper function must
    % be provided.
    
    properties (Access=private, Hidden=true)
        % Stored properties - but kept private and accessible only through
        % public dependent properties
        
        % ---------------
        % Data properties
        % ---------------
        % Cell array (row) with input data as provided by user (i.e. elements
        % may be cell arrays of {x,y,e}, structure arrays, object arrays)
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
        msk_ = {};
        
        % Cell array of masked datasets (row): every entry is either
        %	- an x-y-e triple with wout{i}.x a cell array of arrays, one for 
        %     each x-coordinate,
        %   - a scalar object
        wmask_ = {};
        
        % -------------------
        % Function properties
        % -------------------
        foreground_is_local_ = false;
        
        % Cell array of foreground function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. Missing functions are
        % set to [].
        fun_ = cell(1,0);
        
        % Cell array of the starting foreground function parameters (row vector).
        % If a function is missing the corresponding element of pin_ is [].
        pin_ = cell(1,0);
        
        % Row vector of the number of numeric parameters for each foreground function.
        % If a function is empty, then corresponding element of np_ is 0
        np_ = zeros(1,0);
        
        background_is_local_ = true;
        
        % Cell array of background function handles (row vector). If global function,
        % one handle; if local, one handle per dataset. Missing functions are
        % set to [].
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
        % If a parameter is bound to another, then the value of
        % free_ is that of the parameter to which it is bound.
        free_ = true(0,1);
        
        % Column vector length (nptot_ + nbptot_)
        % =false if parameter is unbound, =true if bound
        bound_ = false(0,1);
        
        % Column vector length (nptot_ + nbptot_)
        % =0 if parameter is unbound; ~=0 index of parameter to
        % which the parameter is bound (in range 1 to (nptot_ + nbptot_))
        bound_to_ = zeros(0,1);
        
        % Column vector length (nptot_ + nbptot_) with ratio of
        % bound parameter to fixed parameter; =0 if a parameter is unbound
        ratio_ = NaN(0,1);
        
        % Sparse square array with ith column containing 0 for 
        % parameters not bound to the ith parameter, or 1 when
        % they are bound. (Note: the total number of non-zero elements
        % cannot exceed (nptot_ + nbptot_ - 1)
        bound_from_ = sparse(0,0);
        
        % -------------------------
        % Output control properties
        % -------------------------
        % Level at which messages are output: 0,1,2
        info_level = 0
        
    end
    
    properties (Dependent)
        data
        w       % *** get rid of for release
        msk     % *** get rid of for release
        
        local_foreground
        global_foreground
        fun
        pin
        pfree
        pbind

        local_background
        global_background
        bfun
        bpin
        bpfree
        bpbind
    end
    
    properties (SetAccess = private)
        wout
        fitdata
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj = mfclass(varargin)
            % Interpret input arguments as solely data
            try
                obj = set_data(obj,varargin{:});
            catch ME
                error(ME.message)
            end
        end
        
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
            if ~islognumscalar(val), error('global_foreground must be a logical scalar'), end
            isfore = false;
            obj = function_set_scope_ (obj, isfore, val);
        end

        %------------------------------------------------------------------
        % Get methods
        function data = get.data(obj)
            data = obj.data_;
        end
        
        function data = get.w(obj)   % *** get rid off for release
            data = obj.w_;
        end
        
        function data = get.msk(obj)   % *** get rid off for release
            data = obj.msk_;
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
        
        function out = get.pbind(obj)
            % *** Need to extract in different form for production version
            nptot = sum(obj.np_);
            out = [double(obj.free_(1:nptot))';...
                double(obj.bound_(1:nptot))';...
                obj.bound_to_(1:nptot)';...
                obj.ratio_(1:nptot,:)'];
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
        
        function out = get.bpbind(obj)
            % *** Need to extract in different form for production version
            nptot = sum(obj.np_);
            nbptot = sum(obj.nbp_);
            range = nptot+1:nptot+nbptot;
            out = [double(obj.free_(range))';...
                double(obj.bound_(range))';...
                obj.bound_to_(range)';...
                obj.ratio_(range,:)'];
        end
        
        %------------------------------------------------------------------
    end
    
    methods (Access = private)
        obj = set_fun_props_ (obj, S)       
        obj = set_constraints_props_ (obj, S)
        
        S = get_fun_props_ (obj)
        S = get_constraints_props_ (obj)
            
        obj = function_set_scope_(obj, isfore, set_local)
        
        [ok, mess, obj] = set_fun_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_fun_private_ (obj, isfore, ifun)
        
        [ok, mess, obj] = set_free_private_ (obj, isfore, args)
        
        [ok, mess, obj] = add_bind_private_ (obj, isfore, args)
        [ok, mess, obj] = clear_bind_private_ (obj, isfore, ifun)
        
    end
    
end
