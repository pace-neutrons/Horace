function pbin = default_pbin_(obj,ndim)
% DEFAULT_PBIN_ Defines default binning for dimensions-only construction of
% the sphere_axes class

default_range  = mat2cell(obj.default_img_range',[1,1,1,1])';
rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
pbin=[default_range(1:ndim),rest];
