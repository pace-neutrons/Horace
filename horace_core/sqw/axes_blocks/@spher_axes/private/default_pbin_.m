function pbin = default_pbin_(obj,ndim)
% UNTITLED3 Defines binning for dimensions-only construction

if obj.angles_in_rad_(1)
    thetar = [-pi/2,pi/2];
else
    thetar = [-90,90];
end
if obj.angles_in_rad_(2)
    phir = [-pi,pi];
else
    phir = [-180,180];
end
default_range = {[0,1],thetar,phir,[0,1]};
rest = arrayfun(@(x)zeros(1,0),1:4-ndim,'UniformOutput',false);
pbin=[default_range(1:ndim),rest];
