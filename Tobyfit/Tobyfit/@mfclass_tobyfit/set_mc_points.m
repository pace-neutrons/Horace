function obj = set_mc_points (obj, val)
% Set the number of Monte Carlo points per pixel
%
%   >> obj = obj.set_mc_points          % set default value
%   >> obj = obj.set_mc_points (n)      % set to the given value

if nargin==1 || isempty(val)
    obj.mc_points_ = 10;
elseif isnumeric(val) && isfinite(val) && val>0 && (rem(val,1)==0 || nif(obj.wrapfun.fun_wrap))
    obj.mc_points_ = val;
else
    error ('Number of Monte Carlo points per pixel must be a positive integer')
end

end
function tf=nif(f)
    non_integer_mc_funcs = {@resolution_DGfermi_QE,@resolution_DGfermi_kf};
    tf = any(cellfun(@(x)isequal(x,f),non_integer_mc_funcs));
end