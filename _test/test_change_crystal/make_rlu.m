function rlu = make_rlu (rlu0, lattice0, lattice, rotvec, ang_dev, rad_dev)
% Create input rlu for testing refine_orientation
%
%   >> rlu = make_rlu (rlu0, lattice0, lattice, rotvec, ang_dev, rad_dev)
%
% Input:
% ------
%   rlu0        Positions of Bragg peaks as h,k,l in reference lattice
%              (n x 3 matrix, n=no. reflections)
%   lattice0    Reference lattice parameters [a,b,c,alf,bet,gam] (Angstroms and degrees)
%   lattice     True lattice parameters [a,b,c,alf,bet,gam] (Angstroms and degrees)
%   rotvec      Rotation vector that rotates crystal Cartesian frame of
%              reference lattice to that for true lattice (radians)
%   ang_dev     Maximum deviation of random components of rotation vector
%              use to give random transverse errors to output rlu (radians)
%              Each rlu vector is given diffrerent random error
%   rad_dev     Maximum random fractional error in radial length of output rlu
%              Each rlu vector is given diffrerent random error
%
% Author: T.G.Perring

%[b0,arlu,angrlu,mess] = bmatrix(lattice0(1:3),lattice0(4:6));
[b0,~,~,mess] = bmatrix(lattice0(1:3),lattice0(4:6));
if ~isempty(mess), error(mess), end

[b,~,~,mess] = bmatrix(lattice(1:3),lattice(4:6));
if ~isempty(mess), error(mess), end

rotmat=rotvec_to_rotmat2(rotvec);
vcryst=rotmat*b0*rlu0';

nv=size(rlu0,1);
for iv=1:nv
    drotvec=2*(rand(3,1)-0.5)*ang_dev;
    drotmat=rotvec_to_rotmat2(drotvec);
    vcryst_tmp=drotmat*vcryst(:,iv);  % random rotation
    vcryst_tmp=vcryst_tmp*(1+rad_dev*2*(rand(1)-0.5));
    vcryst(:,iv)=vcryst_tmp;
end
rlu=(b\vcryst)';
