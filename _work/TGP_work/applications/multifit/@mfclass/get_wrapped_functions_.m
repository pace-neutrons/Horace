function [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
% Get the wrapped function and parameter lists
%
%   >> [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
%
% Functions that are not defined are not wrapped


[fun, p] = cellfun(@(x,y)convert(x,y,obj.fun_wrap_,obj.p_wrap_), obj.fun_, obj.pin_,...
    'uniformOutput', false);
[bfun, bp] = cellfun(@(x,y)convert(x,y,obj.bfun_wrap_,obj.bp_wrap_), obj.bfun_, obj.bpin_,...
    'uniformOutput', false);

%--------------------------------------------------------------------------------------------------
function [fun_out, p_out] = convert (fun, p, fun_wrap, p_wrap)
if ~isempty(fun)
    fun_out = fun_wrap;
    p_out = [{fun, p}, p_wrap];
else
    fun_out = fun;
    p_out = p;
end
