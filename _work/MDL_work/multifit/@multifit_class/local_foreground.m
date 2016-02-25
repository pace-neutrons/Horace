function obj = local_foreground(obj,val)
% Field to specify if foreground fit functions are local to each dataset
%
% If the functions are local, then a valid function handle has to be given
% for each dataset.
%
% See also: 
% <a href="matlab:doc multifit_class/global_foreground">multifit/global_foreground</a>
% <a href="matlab:doc multifit_class/local_background">multifit/local_background</a>
% <a href="matlab:doc multifit_class/global_background">multifit/global_background</a>

if nargin==1
    obj.foreground_is_local
    return
end

if val
    obj.foreground_is_local = true;
else
    if ~isscalar(obj.ffun)
        obj.foreground_is_local = true;
        error('Cannot set foreground functions to be global: Fit function handles is not scalar');
    end
    obj.foreground_is_local = true;
end
