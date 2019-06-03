function  obj=set_shift_transf(obj)
% Define shift transformation, used by advanced combine_equivalent_zones
% algrithm and shifts the coordinates of one zone into the center of another one
%
% resets any matrix transformations to unit transformaton if any
% was defined
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%
obj=obj.clear_transformations();
obj.shift = obj.target_center - obj.zone_center;
obj.transf_matrix_ = eye(3);

