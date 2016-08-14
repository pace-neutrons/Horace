function [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
% Get the wrapped function and parameter lists
%
%   >> [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
%
% Functions that are not defined are not wrapped

wrapfun = obj.wrapfun_;
[fun, p] = cellfun(@(x,y)convert(x,y,wrapfun.fun_wrap,wrapfun.p_wrap), obj.fun_, obj.pin_,...
    'uniformOutput', false);
[bfun, bp] = cellfun(@(x,y)convert(x,y,wrapfun.bfun_wrap,wrapfun.bp_wrap), obj.bfun_, obj.bpin_,...
    'uniformOutput', false);

%--------------------------------------------------------------------------------------------------
function [fun_out, p_out] = convert (fun, p, fun_wrap, p_wrap)
if ~isempty(fun_wrap) && ~isempty(fun)
    fun_out = fun_wrap;
    p_out = [{fun, p}, p_wrap];
else
    fun_out = fun;
    p_out = p;
end
