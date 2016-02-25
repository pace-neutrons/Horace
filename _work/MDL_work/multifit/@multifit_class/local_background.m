function obj = local_background(obj,val)
% Field to specify if background fit functions are local to each dataset
%
% If the functions are local, then a valid function handle has to be given
% for each dataset.
%
% See also:
% <a href="matlab:doc multifit_class/global_background">multifit/global_background</a>
% <a href="matlab:doc multifit_class/local_foreground">multifit/local_foreground</a>
% <a href="matlab:doc multifit_class/global_foreground">multifit/global_foreground</a>

if val
    obj.background_is_local = true;
else
    if ~isscalar(obj.ffun)
        obj.background_is_local = true;
        error('Cannot set background functions to be global: Fit function handles is not scalar');
    end
    obj.background_is_local = false;
end
