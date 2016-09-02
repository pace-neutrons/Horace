classdef mfclass_wrapfun
    % mfclass_wrapfun object
    %
    % Initialise customisation properties for mfclass
    
    properties
        % Restricted datatype for fitting (if given, it must be a class name)
        dataset_class = '';
        
        % Initialisation function to be called before fitting or simulation
        % Function handle if it is given.
        %
        % The purpose of this function is to allow pre-computation
        % of quantities that speed up the evaluation of the fitting
        % function and place them in persistent storage.
        % The function must have the form:
        %
        % >> [ok,mess,c1,c2,...] = my_init_func(w)   % create c1,c2,...
        % >> [ok,mess,c1,c2,...] = my_init_func      % recover stored
        %                                            % c1,c2,...
        % and to clear any persistent storage:
        % >> my_init_func                            % no input or output arguments
        %
        % where
        %   w       Cell array, where each element is either
        %           - an x-y-e triple with w(i).x a cell array of
        %              arrays, one for each x-coordinate
        %            - a scalar object
        %
        %   ok      True if the pre-processed output c1, c2... was
        %          computed correctly; false otherwise
        %
        %   mess    Error message if ok==false; empty string
        %          otherwise
        %
        %   c1,c2,..Output e.g. lookup tables that can be
        %          pre-computed from the data w
        init_func = [];
    end
    
    properties (Access=private, Hidden=true)
        % Wrapper function for foreground functions: [] or function handle
        fun_wrap_ = [];
        
        % Wrapper parameters for foreground wrap function: cell array (row)
        %   - A recursive nesting of functions and parameter lists:
        %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
        %            :
        %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
        %       p<0> = {[], c1<0>, c2<0>,...}
        %         or = []
        p_wrap_ = [];
        
        % Wrapper function for background functions [] or function handle
        bfun_wrap_ = [];
        
        % Wrapper parameters for background wrap function: cell array (row)
        %   - A recursive nesting of functions and parameter lists:
        %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
        %            :
        %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
        %       p<0> = {[], c1<0>, c2<0>,...}
        %         or = []
        bp_wrap_ = [];
    end
    
    properties (Dependent)
        % Wrapper function for foreground functions: [] or function handle
        fun_wrap
        
        % Wrapper parameters for foreground wrap function: cell array (row)
        %   - A recursive nesting of functions and parameter lists:
        %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
        %            :
        %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
        %       p<0> = {[], c1<0>, c2<0>,...}
        %         or = []
        p_wrap
        
        % Wrapper function for background functions: [] or function handle
        bfun_wrap
        
        % Wrapper parameters for background wrap function: cell array (row)
        %   - A recursive nesting of functions and parameter lists:
        %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
        %            :
        %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
        %       p<0> = {[], c1<0>, c2<0>,...}
        %         or = []
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
            %   >> obj = mfclass_wrapfun (dataset_class, fun_wrap, p_wrap, bfun_wrap, b_wrap, init_func)
            
            if numel(varargin)>0
                obj.dataset_class = varargin{1};
                if numel(varargin)==5 || numel(varargin)==6
                    obj.fun_wrap = varargin{2};
                    obj.p_wrap = varargin{3};
                    obj.bfun_wrap = varargin{4};
                    obj.bp_wrap = varargin{5};
                    if numel(varargin)==6
                        obj.init_func = varargin{6};
                    end
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
            if isempty(val)
                obj.dataset_class = '';
            else
                if ischar(val) && numel(size(val))==2 && size(val,1)==1
                    obj.dataset_class = val;
                else
                    error ('Dataset_class must be a character string with the class name')
                end
            end
        end
        
        function obj = set.init_func (obj, val)
            if isempty(val)
                obj.init_func = [];
            else
                if isa(val,'function_handle')
                    obj.init_func = val;
                else
                    error ('Initialisation function must be a function handle')
                end
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
                    obj.p_wrap_ = [];   % reset
                end
            elseif isa(val,'function_handle')
                obj.fun_wrap_ = val;
            else
                error ('The foreground function wrapper must be a function handle')
            end
        end
        
        function obj = set.p_wrap (obj,val)
            if isempty(val)
                obj.p_wrap_ = [];
            else
                if ~isempty(obj.fun_wrap_)
                    if plist_parse_single (val)
                        obj.p_wrap_ = val;
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
                    obj.bp_wrap_ = [];   % reset
                end
            elseif isa(val,'function_handle')
                obj.bfun_wrap_ = val;
            else
                error ('The background function wrapper must be a function handle')
            end
        end
        
        function obj = set.bp_wrap (obj,val)
            if isempty(val)
                obj.bp_wrap_ = [];
            else
                if ~isempty(obj.bfun_wrap_)
                    if plist_parse_single (val)
                        obj.bp_wrap_ = val;
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

%--------------------------------------------------------------------------------------------------
function ok = plist_parse_single (plist)
% Check that a parameter wrapper list has valid format
%
%   >> ok = plist_parse (plist)
%
% Input:
% ------
%   plist   Parameter wrapper list
%
% Output:
% -------
%   ok      Status flag: =true if plist_in is valid; false otherwise
%
%
% Format of a valid parameter wrapper list
% ----------------------------------------
% A valid parameter wrapper list is the same as a parameter list, except that
% at the lowest level the numeric vector p must be empty. It therefore has one
% of the following forms:
%
%   - Empty argument []
%
%   - A cell array of constant parameters
%       e.g.  {c1, c2}
%
%   - A recursive nesting of functions and parameter lists:
%       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%            :
%       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
%       p<0> = {[], c1<0>, c2<0>,...}
%         or = []
%
%     This defines a recursive form for the parameter list that it is assumed
%     the functions in argument func accept:
%       p<0> = []
%         or = {[], c1<0>, c2<0>, ...}
%
%       p<1> = {@func<0>, p<0>, c1<1>, c1<2>,...}
%
%       p<2> = {@func<1>, {@func<0>, p<0>, c1<1>, c2<1>,...}, c1<2>, c2<2>,...}
%            :
%
% When recursively nesting functions and parameter lists, there can be any
% number of additional arguments c1, c2,... , including the case of no
% additional arguments.
% For example, the following are valid
%       []
%       {@myfunc}
%       {@myfunc1,{@myfunc}}


ok=false;
if iscell(plist) && numel(plist)>=2 && numel(size(plist))==2 && size(plist,1)==1
    if isa(plist{1},'function_handle')
        ok=plist_parse_single(plist{2});
    elseif isnumeric(plist{1}) && isempty(plist{1})
        ok=true;
    end
elseif isnumeric(plist) && isempty(plist)
    ok=true;
end

end
