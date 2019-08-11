function status = mosaic_crystal(obj)
% Determine if the mosaic corresponds to the default of no mosaic spread
%
%   >> status = mosaic_crystal(obj)
%
% Input:
% ------
%   obj     IX_mosaic object or array of objects
%
% Ouptut:
% -------
%   status  Logical array same size as obj:
%           - true where there is mosaic spread
%           - false where the mosaic is zero


default_mosaic = IX_mosaic(0);
if isscalar(obj)
    status = ~isequal(obj,default_mosaic);
else
    status = arrayfun(@(x)(~isequal(x,default_mosaic)), obj);
end
