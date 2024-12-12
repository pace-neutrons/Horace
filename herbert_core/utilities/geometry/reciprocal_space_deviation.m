function dist = reciprocal_space_deviation (x1,x2,x3,p,rlu_expected)
% Function to calculate the distance between a points in reciprocal space
% and corresponding point in a reference orthonormal frame
%
%   >> dist = reciprocal_space_deviation (v0,p,rlu_expected)
%
% Input:
% -------
%   x1,x2,x3    Arrays of coordinates in reference crystal Cartesian coordinates
%               This is 3 at least n-length vectors representing n x 3 array
%               of actual coordinates to calculate distances.
%               The arrays may contain the same data repeated three times
%               along first dimension.
%   p           Parameters that can be fitted: [a,b,c,alph,bet,gam,theta1,theta2,theta3]
%               a,b,c           lattice parameters (Ang)
%               alph,bet,gam     lattice angles (deg)
%               theta1,theta2,theta3    components of rotation vector linking
%                                          crystal Cartesian coordinates
%                                           v(i)=R_theta(i,j)*v0(j)
%   rlu_expected   Components along a*, b*, c* in lattice defined by p (n x 3 array)
%               and expressed in hkl coordinate system.
%
% Output:
% -------
%   dist        Column vector of deviations along x,y,z axes of reference crystal
%              Cartesian coordinates for each of the vectors rlu_expected in turn

nv=size(rlu_expected,1);

alatt=p(1:3);
angdeg=p(4:6);
rotvec=p(7:9);

b=bmatrix(alatt,angdeg);
R=rotvec_to_rotmat_rad(rotvec);
rlu_to_cryst0=R\b;
v=(rlu_to_cryst0*rlu_expected')';
dv=v-[x1(1:nv),x2(1:nv),x3(1:nv)];

dist=reshape(dv',3*nv,1)./repmat(sqrt(sum(v.^2,2)),3,1);
