classdef mfclass_wrapfun
    % mfclass_wrapfun object
    %
    % Initialise customisation properties for mfclass
    
    properties
        % Restricted datatype for fitting (if given, it must be a class name)
        dataset_class = '';
        
        % Return type: false if no status to keep, true if status to keep
        f_pass_caller = false;
        
        % Return type: false if no status to keep, true if status to keep
        bf_pass_caller = false;
        
end
    
    properties (Access=private, Hidden=true)
        % Wrapper function for foreground functions: [] or function handle
        fun_wrap_ = [];
        
        % Wrapper parameters for foreground wrap function: cell array (row)
        p_wrap_ = [];
        
        % Wrapper function for background functions [] or function handle
        bfun_wrap_ = [];
        
        % Wrapper parameters for background wrap function: cell array (row)
        bp_wrap_ = [];

        % Initialisation function for foreground, called before fitting or simulation
        func_init_ = [];

        % Initialisation function for background, called before fitting or simulation
        bfunc_init_ = [];

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

        % Initialisation function for foreground, called before fitting or simulation
        % Function handle if it is given.
        %
        % The purpose of this function is to allow pre-computation
        % of quantities that speed up the evaluation of the fitting
        % function. These quantities will be inserted as the
        % first constant argument(s) of the wrapper parameter argument p_wrap
        % that will be passed to the wrapper function.
        %
        % The function must have the form:
        %
        % >> [ok,mess,args] = my_func_init(w)
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
        %   args    Cell array with output arguments e.g. lookup tables that
        %          can be pre-computed from the data w.
        %           If there is just one argument, then this must still be
        %          placed in a cell array by the function
        func_init
        
        % Initialisation function for background, called before fitting or simulation
        % Function handle if it is given.
        %
        % The purpose of this function is to allow pre-computation
        % of quantities that speed up the evaluation of the fitting
        % function. These quantities will be inserted as the
        % first constant argument(s) of the wrapper parameter argument p_wrap
        % that will be passed to the wrapper function.
        %
        % See the help for the property 'func_init' for description of the
        % intialisation function i/o, which is identical to this.
        bfunc_init
    
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
            %   >> obj = mfclass_wrapfun (dataset_class, fun_wrap, p_wrap, bfun_wrap, b_wrap,...
            %                               f_pass_caller, bf_pass_caller)
            %   >> obj = mfclass_wrapfun (dataset_class, fun_wrap, p_wrap, bfun_wrap, b_wrap,...
            %                               f_pass_caller, bf_pass_caller, func_init, bfunc_init)
            
            if numel(varargin)>0
                obj.dataset_class = varargin{1};
                if numel(varargin)==5 || numel(varargin)==7 || numel(varargin)==9
                    obj.fun_wrap = varargin{2};
                    obj.p_wrap = varargin{3};
                    obj.bfun_wrap = varargin{4};
                    obj.bp_wrap = varargin{5};
                    if numel(varargin)>=7
                        obj.f_pass_caller = varargin{6};
                        obj.bf_pass_caller = varargin{7};
                    end
                    if numel(varargin)>=9
                        obj.func_init = varargin{8};
                        obj.bfunc_init = varargin{9};
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
                    error ('''dataset_class'' must be a character string with the class name')
                end
            end
        end
        
        function obj = set.f_pass_caller (obj, val)
            if isempty(val)
                obj.f_pass_caller = false;
            else
                if islognumscalar(val)
                    obj.f_pass_caller = logical(val);
                else
                    error ('''f_pass_caller'' must be a logical scalar (or 0 or 1)')
                end
            end
        end
        
        function obj = set.bf_pass_caller (obj, val)
            if isempty(val)
                obj.bf_pass_caller = false;
            else
                if islognumscalar(val)
                    obj.bf_pass_caller = logical(val);
                else
                    error ('''f_pass_caller'' must be a logical scalar (or 0 or 1)')
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
                if ~isempty(obj.func_init_)
                    obj.func_init_ = [];   % reset
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
                    if plist_parse (val)
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
                if ~isempty(obj.bfunc_init_)
                    obj.bfunc_init_ = [];   % reset
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
                    if plist_parse (val)
                        obj.bp_wrap_ = val;
                    else
                        error ('The wrapper parameter list must be a row cell array or a single non-cell array argument')
                    end
                else
                    error ('The wrapper parameter list must be empty if no wrapper function is given')
                end
            end
        end
        
        function obj = set.func_init (obj, val)
            if isempty(val)
                obj.func_init_ = [];
            else
                if ~isempty(obj.fun_wrap_)
                    if isa(val,'function_handle')
                        obj.func_init_ = val;
                    else
                        error ('Initialisation function must be a function handle')
                    end
                else
                    error ('There must be a foreground wrapper function to be able to set the foreground initialisation function')
                end
            end
        end
        
        function obj = set.bfunc_init (obj, val)
            if isempty(val)
                obj.bfunc_init_ = [];
            else
                if ~isempty(obj.bfun_wrap_)
                    if isa(val,'function_handle')
                        obj.bfunc_init_ = val;
                    else
                        error ('Initialisation function must be a function handle')
                    end
                else
                    error ('There must be a background wrapper function to be able to set the background initialisation function')
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
        
        function out = get.func_init (obj)
            out = obj.func_init_;
        end
        
        function out = get.bfunc_init (obj)
            out = obj.bfunc_init_;
        end
        
        %------------------------------------------------------------------
        % Other methods
        %------------------------------------------------------------------
        function obj = append_p_wrap (obj, varargin)
            % Append arguments to the wrapper parameters for foreground wrap functions.
            %
            %   >> obj = obj.append_p_wrap (c1, c2,...)
            obj.p_wrap = append_cell (obj.p_wrap, varargin{:});
        end

        function obj = prepend_p_wrap (obj, varargin)
            % Prepend arguments to the wrapper parameters for foreground wrap functions.
            %
            %   >> obj = obj.prepend_p_wrap (c1, c2,...)
            %
            % The addition arguments become the new c1, c2, in:
            %       p_wrap = {@func, plist, c1, c2,...}
            %       p_wrap = {[], c1, c2,...}
            obj.p_wrap = prepend_cell (obj.p_wrap, varargin{:});
        end

        function obj = append_bp_wrap (obj, varargin)
            % Append arguments to the wrapper parameters for background wrap functions.
            %
            %   >> obj = obj.append_bp_wrap (c1, c2,...)
            obj.bp_wrap = append_cell (obj.bp_wrap, varargin{:});
        end

        function obj = prepend_bp_wrap (obj, varargin)
            % Prepend arguments to the wrapper parameters for foreground wrap functions.
            %
            %   >> obj = obj.prepend_bp_wrap (c1, c2,...)
            %
            % The addition arguments become the new c1, c2, in:
            %       bp_wrap = {@func, bplist, c1, c2,...}
            %       bp_wrap = {[], c1, c2,...}
            obj.bp_wrap = prepend_cell (obj.bp_wrap, varargin{:});
        end

    end
end


%--------------------------------------------------------------------------------------------------
function ok = plist_parse (plist)
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
        ok=plist_parse(plist{2});
    elseif isnumeric(plist{1}) && isempty(plist{1})
        ok=true;
    end
elseif isnumeric(plist) && isempty(plist)
    ok=true;
end

end


%--------------------------------------------------------------------------------------------------
function Cout = append_cell (C, varargin)
% Append arguments to a row cell array. If the inital argument C is not a
% cell array, it becomes the first argument of the output cell array.
% If no arguments are to be appended, then Cout is identical to C (i.e. it
% is NOT changed into a cell array with one element)

if numel(varargin)>0
    if ~iscell(C)
        Cout = [{C},varargin];
    else
        Cout = [C,varargin];
    end
else
    Cout = C;
end

end


%--------------------------------------------------------------------------------------------------
function Cout = prepend_cell (C, varargin)
% Prepend new arguments c1, c2, ... to a row cell array of the form:
%       {@func, plist, c1, c2,...}
%       {[], c1, c2,...}
% or the empty array
%       []
% These are the cases that appear as parameter lists.

if numel(varargin)>0
    if ~iscell(C)           % case of: []
        Cout = [{C},varargin];
    elseif isempty(C{1})    % case of : {[], c1, c2, ...}
        Cout = [C(1),varargin,C(2:end)];
    else                    % case of: {@func, plist, c1, c2, ...}
        Cout = [C(1:2),varargin,C(3:end)];
    end
else
    Cout = C;
end

end
