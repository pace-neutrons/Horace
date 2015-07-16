function new_coord = spher_transform(this,rs)
% Convert grid expressed in input cartesian coordinate sustem into output
% spherical coordinate system.

%TODO : alight appropriately. 
%
ez = this.ez;
ex = this.ex;
[phi,theta,r] = cart2sph(rs(1,:),rs(2,:),rs(3,:));

new_coord=[r;theta*(180./pi);phi*(180./pi)];

