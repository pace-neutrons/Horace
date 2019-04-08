function  obj=set_shift_transf(obj)
% Define shift transformation, used by advanced combine_equivalent_zones
% algrithm and shifts the coordinates of one zone into the center of another one
%
% resets any matrix transformations to unit transformaton if any
% was defined
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
%
obj=obj.clear_transformations();
obj.shift = obj.target_center - obj.zone_center;
obj.transf_matrix_ = eye(3);

