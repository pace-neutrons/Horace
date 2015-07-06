function new_coord = spher_transform(this,rs)
% Convert grid expressed in input cartesian coordinate sustem into output
% spherical coordinate system.

%TODO : alight appropriately. 
%
ez = this.ez;
ex = this.ex;
[r,theta,phi] = cart2pol(rs(1,:),rs(2,:),rs(3,:));

new_coord=[r;theta*(180./pi);phi*(180./pi)];

