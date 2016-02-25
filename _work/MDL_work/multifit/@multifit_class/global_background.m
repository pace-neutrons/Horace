function obj = global_background(obj,val)
% Field to specify if there should be only a single global background fit function
%
% This implies that the ffun field must be scalar.
%
% See also:
% <a href="matlab:doc multifit_class/local_background">multifit/local_background</a>
% <a href="matlab:doc multifit_class/local_foreground">multifit/local_foreground</a>
% <a href="matlab:doc multifit_class/global_foreground">multifit/global_foreground</a>

if ~val
    obj.background_is_local = true;
else
    if ~isscalar(obj.bfun)
        obj.background_is_local = true;
        error('Cannot set background functions to be global: Fit function handles is not scalar');
    end
    obj.background_is_local = false;
end
