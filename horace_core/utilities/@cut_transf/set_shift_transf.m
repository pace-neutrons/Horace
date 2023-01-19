function  obj=set_shift_transf(obj)
% Define shift transformation, used by advanced combine_equivalent_zones
% algorithm and shifts the coordinates of one zone into the centre of another one
%
% resets any matrix transformations to unit transformation if any
% was defined
%
%
obj=obj.clear_transformations();
obj.shift = obj.target_center - obj.zone_center;
obj.transf_matrix_ = eye(3);
