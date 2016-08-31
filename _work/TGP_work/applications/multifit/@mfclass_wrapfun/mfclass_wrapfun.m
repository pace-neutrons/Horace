classdef mfclass_wrapfun
    % mfclass_wrapfun object
    %
    % Initialise customisation properties for mfclass
    
    properties
        % Datatype (must be a class name)
        dataset_class = '';
    end
    
    properties (Access=private, Hidden=true)
        % Wrapper function for foreground functions: [] or function handle
        fun_wrap_ = [];
        
        % Wrapper parameters for foreground wrap function: cell array (row)
        p_wrap_ = {};
        
        % Wrapper function for background functions [] or function handle
        bfun_wrap_ = [];
        
        % Wrapper parameters for background wrap function: cell array (row)
        bp_wrap_ = {};
    end
    
    properties (Dependent)
        % Public access properties - required because of dependencies
        fun_wrap
        p_wrap
        bfun_wrap
        bp_wrap
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_wrapfun(varargin)
            % Create mfclass_wrapfun object:
            %
            %   >> obj = mfclass_wrapfun
            %   >> obj = mfclass_wrapfun (dataset_class)
            %   >> obj = mfclass_wrapfun (dataset_class, fun_wrap, p_wrap, bfun_wrap, b_wrap)
            
            if numel(varargin)>0
                obj.dataset_class = varargin{1};
                if numel(varargin)==5
                    obj.fun_wrap = varargin{2};
                    obj.p_wrap = varargin{3};
                    obj.bfun_wrap = varargin{4};
                    obj.bp_wrap = varargin{5};
                elseif numel(varargin)~=1
                    error ('Check number of input arguments')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Set/get methods: public properties
        %------------------------------------------------------------------
        % Set methods
        function obj = set.dataset_class (obj, val)
            if ~isempty(val) && ischar(val) && numel(size(val))==2 && size(val,1)==1
                obj.dataset_class = val;
            else
                error ('Dataset_class must be a non-empty character string with the class name')
            end
        end
        
        %------------------------------------------------------------------
        % Set/get methods: dependent properties
        %------------------------------------------------------------------
        % Set methods
        function obj = set.fun_wrap (obj,val)
            if isempty(val)
                obj.fun_wrap_ = [];
                if ~isempty(obj.p_wrap_)
                    obj.p_wrap_ = {};   % reset
                end
            elseif isa(val,'function_handle')
                obj.fun_wrap_ = val;
            else
                error ('The foreground function wrapper must be a function handle')
            end
        end
        
        function obj = set.p_wrap (obj,val)
            if isempty(val)
                obj.p_wrap_ = {};
            else
                if ~isempty(obj.fun_wrap_)
                    if iscell(val) && (numel(size(val))==2 && size(val,1)==1)
                        obj.p_wrap_ = val;
                    elseif ~iscell(val)
                        obj.p_wrap_ = {val};
                    else
                        error ('The wrapper parameter list must be a row cell array or a single non-cell array argument')
                    end
                else
                    error ('The wrapper parameter list must be empty if no wrapper function is given')
                end
            end
        end
        
        function obj = set.bfun_wrap (obj,val)
            if isempty(val)
                obj.bfun_wrap_ = [];
                if ~isempty(obj.bp_wrap_)
                    obj.bp_wrap_ = {};   % reset
                end
            elseif isa(val,'function_handle')
                obj.bfun_wrap_ = val;
            else
                error ('The background function wrapper must be a function handle')
            end
        end
        
        function obj = set.bp_wrap (obj,val)
            if isempty(val)
                obj.bp_wrap_ = {};
            else
                if ~isempty(obj.bfun_wrap_)
                    if iscell(val) && (numel(size(val))==2 && size(val,1)==1)
                        obj.bp_wrap_ = val;
                    elseif ~iscell(val)
                        obj.bp_wrap_ = {val};
                    else
                        error ('The wrapper parameter list must be a row cell array or a single non-cell array argument')
                    end
                else
                    error ('The wrapper parameter list must be empty if no wrapper function is given')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Get methods
        function out = get.fun_wrap (obj)
            out = obj.fun_wrap_;
        end
        
        function out = get.p_wrap (obj)
            out = obj.p_wrap_;
        end
        
        function out = get.bfun_wrap (obj)
            out = obj.bfun_wrap_;
        end
        
        function out = get.bp_wrap (obj)
            out = obj.bp_wrap_;
        end
        
    end
end
