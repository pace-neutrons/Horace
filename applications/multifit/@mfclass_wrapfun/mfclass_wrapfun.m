classdef mfclass_wrapfun
    % mfclass_wrapfun object
    %
    % Initialise customised function and parameter wrapping for mfclass
    
    properties (Access=private)
        % Wrapper function for foreground functions: [] or function handle
        fun_wrap_ = [];
        
        % Wrapper parameters for foreground wrap function: if fun_wrap_ is empty
        % will 0x0 array of mfclass_plist
        p_wrap_ = repmat(mfclass_plist(),0,0);
        
        % Wrapper function for background functions [] or function handle
        bfun_wrap_ = [];
        
        % Wrapper parameters for background wrap function: if bfun_wrap_ is empty
        % will 0x0 array of mfclass_plist
        bp_wrap_ = repmat(mfclass_plist(),0,0);
        
        % Return type: false if no status to keep, true if status to keep
        % If fun_wrap_ is empty, then false
        f_pass_caller_ = false;
        
        % Return type: false if no status to keep, true if status to keep
        % If bfun_wrap_ is empty, then false
        bf_pass_caller_ = false;
        
        % Initialisation function for foreground, called before fitting or simulation
        func_init_ = [];
        
        % Initialisation function for background, called before fitting or simulation
        bfunc_init_ = [];
        
    end
    
    properties (Dependent)
        % Wrapper function for foreground functions: [] or function handle
        fun_wrap
        
        % Wrapper parameters for foreground wrap function: object of mfclass_plist
        %   - A recursive nesting of functions and parameter lists:
        %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
        %            :
        %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
        %       p<0> =  p
        %              {p, c1<0>, c2<0>,...}
        %               c1<0>
        %              {c1<0>, c2<0>,...}
        %              {}
        p_wrap
        
        % Wrapper function for background functions: [] or function handle
        bfun_wrap
        
        % Wrapper parameters for background wrap function: object of mfclass_plist
        %   - A recursive nesting of functions and parameter lists:
        %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
        %            :
        %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
        %       p<0> = {[], c1<0>, c2<0>,...}
        %       p<0> =  p
        %              {p, c1<0>, c2<0>,...}
        %               c1<0>
        %              {c1<0>, c2<0>,...}
        %              {}
        bp_wrap
        
        % Determines the form of the foreground fit function argument lists:
        %       If false:
        %           wout = my_func (win, @fun, plist, c1, c2, ...)
        %       If true:
        %           [wout, state_out, store_out] = my_func (win, caller,...
        %                   state_in, store_in, @fun, plist, c1, c2, ...)
        f_pass_caller
        
        % Determines the form of the background fit function argument lists:
        %       If false:
        %           wout = my_func (win, @fun, plist, c1, c2, ...)
        %       If true:
        %           [wout, state_out, store_out] = my_func (win, caller,...
        %                   state_in, store_in, @fun, plist, c1, c2, ...)
        bf_pass_caller
        
        % Initialisation function for foreground, called before fitting or simulation
        % Function handle if it is given.
        %
        % The purpose of this function is to allow pre-computation
        % of quantities that speed up the evaluation of the fitting
        % function. These quantities will be inserted as the
        % first constant argument(s) of the wrapper parameter argument p_wrap
        % that will be passed to the wrapper function, or if there is no wrapper
        % function, as the first constant argument(s) of the fit function.
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
        %           depending on whether the corresponding input dataset was
        %          x-y-e data or an object
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
        % that will be passed to the wrapper function, or if there is no wrapper
        % function, as the first constant argument(s) of the fit function.
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
            %   >> obj = mfclass_wrapfun (fun_wrap, p_wrap, bfun_wrap, bp_wrap)
            %   >> obj = mfclass_wrapfun (fun_wrap, p_wrap, bfun_wrap, bp_wrap,...
            %                               f_pass_caller, bf_pass_caller)
            %   >> obj = mfclass_wrapfun (fun_wrap, p_wrap, bfun_wrap, bp_wrap,...
            %                               f_pass_caller, bf_pass_caller,...
            %                               func_init, bfunc_init)
            
            if numel(varargin)>0
                if numel(varargin)==4 || numel(varargin)==6 || numel(varargin)==8
                    % Populate with public set routines to ensure checks are performed
                    obj.fun_wrap = varargin{1};
                    obj.p_wrap = varargin{2};
                    obj.bfun_wrap = varargin{3};
                    obj.bp_wrap = varargin{4};
                    if numel(varargin)>=6
                        obj.f_pass_caller = varargin{5};
                        obj.bf_pass_caller = varargin{6};
                    end
                    if numel(varargin)>=8
                        obj.func_init = varargin{7};
                        obj.bfunc_init = varargin{8};
                    end
                else
                    error ('Check number of input arguments')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Set/get methods: dependent properties
        %------------------------------------------------------------------
        % Set methods
        function obj = set.fun_wrap (obj, val)
            % Set wrapper function. Must be function handle or []
            if isempty(val)
                obj.fun_wrap_ = [];
                if ~isempty(obj.p_wrap_)
                    obj.p_wrap_ = repmat(mfclass_plist(),0,0);
                    obj.f_pass_caller_ = false;
                end
            elseif isa(val,'function_handle')
                obj.fun_wrap_ = val;
                if isempty(obj.p_wrap)
                    obj.p_wrap = mfclass_plist();   % update to a non-empty blank plist
                end
            else
                error ('The foreground function wrapper must be a function handle')
            end
        end
        
        function obj = set.p_wrap (obj, val)
            if ~isempty(obj.fun_wrap_)
                % Scalar plist accepted as p_wrap
                if ~(isa(val,'mfclass_plist') && isscalar(val))
                    obj.p_wrap_ = mfclass_plist(val);
                else
                    obj.p_wrap_ = val;
                end
            else
                if isempty(val)
                    % Empty function allows an empty argument to be interpreted as empty plist
                    obj.p_wrap_ = repmat(mfclass_plist(),0,0);
                else
                    error ('The wrapper parameter list must be empty because thre is no foreground wrapper function')
                end
            end
        end
        
        function obj = set.bfun_wrap (obj, val)
            % Set wrapper function. Must be function handle or []
            if isempty(val)
                obj.bfun_wrap_ = [];
                if ~isempty(obj.bp_wrap_)
                    obj.bp_wrap_ = repmat(mfclass_plist(),0,0);
                    obj.bf_pass_caller_ = false;
                end
            elseif isa(val,'function_handle')
                obj.bfun_wrap_ = val;
                if isempty(obj.bp_wrap)
                    obj.bp_wrap = mfclass_plist();   % update to a non-empty blank plist
                end
            else
                error ('The foreground function wrapper must be a function handle')
            end
        end
        
        function obj = set.bp_wrap (obj, val)
            if ~isempty(obj.bfun_wrap_)
                % Scalar plist accepted as bp_wrap
                if ~(isa(val,'mfclass_plist') && isscalar(val))
                    obj.bp_wrap_ = mfclass_plist(val);
                else
                    obj.bp_wrap_ = val;
                end
            else
                if isempty(val)
                    % Empty function allows an empty argument to be interpreted as empty plist
                    obj.bp_wrap_ = repmat(mfclass_plist(),0,0);
                else
                    error ('The wrapper parameter list must be empty because thre is no background wrapper function')
                end
            end
        end
        
        function obj = set.f_pass_caller (obj, val)
            if isempty(val)
                obj.f_pass_caller_ = false;
            else
                if islognumscalar(val)
                    if ~isempty(obj.fun_wrap) || ~logical(val)
                        obj.f_pass_caller_ = logical(val);
                    else
                        error ('''f_pass_caller'' cannot be true if no foreground function wrapper has been set')
                    end
                else
                    error ('''f_pass_caller'' must be a logical scalar (or 0 or 1)')
                end
            end
        end
        
        function obj = set.bf_pass_caller (obj, val)
            if isempty(val)
                obj.bf_pass_caller_ = false;
            else
                if islognumscalar(val)
                    if ~isempty(obj.bfun_wrap) || ~logical(val)
                        obj.bf_pass_caller_ = logical(val);
                    else
                        error ('''bf_pass_caller'' cannot be true if no background function wrapper has been set')
                    end
                else
                    error ('''f_pass_caller'' must be a logical scalar (or 0 or 1)')
                end
            end
        end
        
        function obj = set.func_init (obj, val)
            if isempty(val)
                obj.func_init_ = [];
            else
                if isa(val,'function_handle')
                    obj.func_init_ = val;
                else
                    error ('Initialisation function must be a function handle')
                end
            end
        end
        
        function obj = set.bfunc_init (obj, val)
            if isempty(val)
                obj.bfunc_init_ = [];
            else
                if isa(val,'function_handle')
                    obj.bfunc_init_ = val;
                else
                    error ('Initialisation function must be a function handle')
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
        
        function out = get.f_pass_caller (obj)
            out = obj.f_pass_caller_;
        end
        
        function out = get.bf_pass_caller (obj)
            out = obj.bf_pass_caller_;
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
        function [ok, mess, fun_out, p_out, bfun_out, bp_out] = ...
                wrap_functions_and_parameters (obj, w, fun, p, bfun, bp)
            % Get wrapped function and parameter lists
            %
            %   >> [ok, mess, fun_out, p_out, bfun_out, bp_out] = ...
            %     wrap_functions_and_parameters (obj, w, fun, p, bfun, bp)
            %
            % Input:
            % ------
            %   w           Data. This should be the data that will actually be
            %              simulated or fitted, that is, after all masking and
            %              in the case of fitting the removal of unfittable data.
            %              This is because the output of the initialisation
            %              functions may depend on the detialsof the data.
            %
            %   fun         Cell array of foreground function handles; missing functions
            %              are set to []
            %
            %   p           Array of type mfclass_plist containing foreground parameter
            %              lists. Missing functions have value mfclass_plist()
            %
            %   bfun        Cell array of background function handles; missing functions
            %              are set to []
            %
            %   bp          Array of type mfclass_plist containing background parameter
            %              lists. Missing functions have value mfclass_plist()
            %
            % Output:
            % -------
            %   ok          True if all OK, false if not
            %
            %   mess        Error message if not OK; '' if all OK
            %
            %   fun_out, p_out, bfun_out, bp_out
            %               Functions and parameter lists wrapped by the wrapper arguments
            %              and including the initialisation parameters, if required.
            %               If an input function was missing, then the corresponding
            %              output function is also missing - wrapping is not performed on
            %              missing functions
                        
            f_present = cellfun(@(x)~isempty(x),fun);
            bf_present = cellfun(@(x)~isempty(x),bfun);
            
            % If initialisation function given, get arguments
            [ok, mess, f_init_args] = init_args (w, f_present, obj.func_init_, 'Foreground');
            if ~ok, fun_out = fun; p_out = p; bfun_out = bfun; bp_out = bp; return, end
            
            if isequal(obj.func_init_, obj.bfunc_init_) && any(f_present(:))
                bf_init_args = f_init_args; % save unnecessary repetition of calculation
            else
                [ok, mess, bf_init_args] = init_args (w, bf_present, obj.bfunc_init_, 'Background');
                if ~ok, fun_out = fun; p_out = p; bfun_out = bfun; bp_out = bp; return, end
            end
            
            % Wrap functions and parameters
            [fun_out, p_out] = wrap_f_and_p...
                (fun, p, f_present, obj.fun_wrap_, obj.p_wrap_, f_init_args);
            [bfun_out, bp_out] = wrap_f_and_p...
                (bfun, bp, bf_present, obj.bfun_wrap_, obj.bp_wrap_, bf_init_args);
            
        end
        
    end
end

%--------------------------------------------------------------------------------------------------
function [ok, mess, f_init_args] = init_args (w, f_present, func_init, str)
% Get arguments from initialisation function
ok = true;
mess = '';
f_init_args={};
if ~isempty(func_init) && any(f_present(:))
    [ok,mess,f_init_args]=func_init(w);
    if ~ok
        mess = [str,' preprocessor function: ',mess];
        return
    elseif ~iscell(f_init_args) || isempty(f_init_args) || ~isrowvector(f_init_args)
        ok=false;
        mess = [str,' preprocessor function must return the '...
            'initialiation arguments in a single, non-empty, row cell array'];
        return
    end
end

end

%--------------------------------------------------------------------------------------------------
function [fun_out, p_out] = wrap_f_and_p (fun, p, f_present, fun_wrap, p_wrap, f_init_args)
% Wrap functions and parameter lists. It is assumed that the initialisation
% parameters are to be the first parameters in the top-most function call
fun_out = fun;
p_out = p;
if any(f_present(:))
    if ~isempty(fun_wrap)
        % Wrap the non-empty functions
        fun_out(f_present) = {fun_wrap};
        p_wrap = prepend_args(p_wrap, f_init_args{:});
        for i=1:numel(fun)
            if f_present(i)
                p_out(i) = wrap(p(i), fun{i}, p_wrap);
            end
        end
    else
        % Prepend initial arguments to non-empty function parameter lists
        for i=1:numel(fun)
            if f_present(i)
                p_out(i) = prepend_args(p(i), f_init_args{:});
            end
        end
    end
end

end
