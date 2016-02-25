function obj = global_foreground(obj,val)
% Field to specify if there should be only a single global foreground fit function
%
% This implies that the ffun field must be scalar.
%
% See also:
% <a href="matlab:doc multifit_class/local_foreground">multifit/local_foreground</a>
% <a href="matlab:doc multifit_class/local_background">multifit/local_background</a>
% <a href="matlab:doc multifit_class/global_background">multifit/global_background</a>

if nargin==1
    ~(obj.foreground_is_local)
    return
end

if ~val
    obj.foreground_is_local = true;
else
    if ~isscalar(obj.ffun)
        obj.foreground_is_local = true;
        error('Cannot set foreground functions to be global: Fit function handles is not scalar');
    end
    obj.foreground_is_local = true;
end
