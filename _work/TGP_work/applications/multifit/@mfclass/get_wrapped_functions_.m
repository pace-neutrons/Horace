function [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
% Get the wrapped function and parameter lists
%
%   >> [fun, p, bfun, bp] = get_wrapped_functions_ (obj)
%
% Functions that are not defined are not wrapped

custom = obj.custom_;
[fun, p] = cellfun(@(x,y)convert(x,y,custom.fun_wrap,custom.p_wrap), obj.fun_, obj.pin_,...
    'uniformOutput', false);
[bfun, bp] = cellfun(@(x,y)convert(x,y,custom.bfun_wrap,custom.bp_wrap), obj.bfun_, obj.bpin_,...
    'uniformOutput', false);

%--------------------------------------------------------------------------------------------------
function [fun_out, p_out] = convert (fun, p, fun_wrap, p_wrap)
if ~isempty(fun_wrap)
    fun_out = fun_wrap;
    p_out = [{fun, p}, p_wrap];
else
    fun_out = fun;
    p_out = p;
end
