function [fun, p, bfun, bp] = get_wrapped_functions_ (obj,...
    func_init_output_args, bfunc_init_output_args)
% Get the wrapped function and parameter lists
%
%   >> [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
%   >> [fun, p, bfun, bp] = get_wrapped_functions_ (obj,...
%                           func_init_output_args, bfunc_init_output_args)
%
% Input:
% ------
%   func_init_output_args       Cell array containing arguments returned by 
%                              foreground initialisation function. If none,
%                              then set to {}.
%
%   bfunc_init_output_args      Cell array containing arguments returned by 
%                              background initialisation function. If none,
%                              then set to {}.
%
% Output:
% -------
%   fun, p, bfun, bp            Functions and paramater lists wrapped by
%                              the wrapper arguments and including the 
%                              initialisation parameters, if required.

% Check input. In principle, because this is an internally used function only,
% catch mis-use by developers!
if nargin==3
    if ~iscell(func_init_output_args) || ~iscell(bfunc_init_output_args)
        error ('Check input arguments - see Developers')
    end
elseif nargin==1
    func_init_output_args = {};
    bfunc_init_output_args = {};
else
    error ('Check input arguments - see Developers')
end

% Get wrapped functions
wrapfun = obj.wrapfun_;
wrapfun = wrapfun.prepend_p_wrap (func_init_output_args{:});
wrapfun = wrapfun.prepend_p_wrap (bfunc_init_output_args{:});

[fun, p] = cellfun(@(x,y)wrap(x,y,wrapfun.fun_wrap,wrapfun.p_wrap), obj.fun_, obj.pin_,...
    'uniformOutput', false);
[bfun, bp] = cellfun(@(x,y)wrap(x,y,wrapfun.bfun_wrap,wrapfun.bp_wrap), obj.bfun_, obj.bpin_,...
    'uniformOutput', false);


%--------------------------------------------------------------------------------------------------
function [fun_out, p_out] = wrap (fun, p, fun_wrap, p_wrap)
% Wrap the function and parameter list.
%
%   >> [fun_out, p_out] = wrap (fun, p, fun_wrap, p_wrap)
%
%
% Format of a valid parameter list
% --------------------------------
% A valid parameter list is one of the following:
%   - A numeric vector with at zero or more elements e.g. p=[10,100,0.01]
%   
%   - A cell array of parameters, the first of which is a numeric vector with
%    zwero or more element
%       e.g.  {p, c1, c2}
%
%   - A recursive nesting of functions and parameter lists:
%       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%            :
%       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
%       p<0> = {p, c1<0>, c2<0>,...}        % p is a numeric vector
%         or =  p                           % p is a numeric vector
%
%     This defines a recursive form for the parameter list that it is assumed
%     the functions in argument func accept:
%       p<0> = p               numeric vector
%         or ={p, c1<0>, c2<0>, ...} cell array, with first parameter a numeric vector
%
%       p<1> = {@func<0>, p<0>, c1<1>, c1<2>,...}
%
%       p<2> = {@func<1>, {@func<0>, p<0>, c1<1>, c2<1>,...}, c1<2>, c2<2>,...}
%            :
%
% When recursively nesting functions and parameter lists, there can be any
% number of additional arguments c1, c2,... , including the case of no
% additional arguments.
% For example, the following are valid (p a numeric array):
%        p
%       {@myfunc,p}
%       {@myfunc1,{@myfunc,p}}
% but these are not valid:
%       {p}
%       {@myfunc,{p}}
%
%
% Format of a valid parameter wrapper list
% ----------------------------------------
% A valid parameter wrapper list is the same as a parameter list, except that
% at the lowest level it is missing the numeric vector p. It therefore has one
% of the following forms:
%
%   - Empty argument
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
%        []
%       {@myfunc}
%       {@myfunc1,{@myfunc}}


% Wrap the function and parameter list.
% - If the wrapper function is empty, this means no wrapping to be done (the
%   wrapper list will by construction be empty)
% - If fun is empty, then this means that no function is required, so do not
%   wrap
if ~isempty(fun_wrap) && ~isempty(fun)
    fun_out = fun_wrap;
    p_out = wrap_p (fun, p, p_wrap);
else
    fun_out = fun;
    p_out = p;
end


%--------------------------------------------------------------------------------------------------
function p_out = wrap_p (fun, p, pwrap)
% Create the wrapped parameter list

if iscell(pwrap) && ~isempty(pwrap)
    if isa(pwrap{1},'function_handle')
        p_out={pwrap{1},wrap_p(fun,p,pwrap{2}),pwrap{3:end}};
    else
        p_out={fun,p,pwrap{2:end}};
    end
else
    p_out={fun,p};
end
