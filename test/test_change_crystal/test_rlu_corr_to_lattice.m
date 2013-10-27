function test_rlu_corr_to_lattice
% Test rlu_corr_to_lattice
%
% Author: T.G.Perring

eps=1e-12;

alatt0=[5,6,7];
angdeg0=[85,120,95];
alatt=[6,5,8];
angdeg=[92,110,75];
rotvec=(pi/180)*[4,28,94];

b0=bmatrix(alatt0,angdeg0);
b=bmatrix(alatt,angdeg);
rotmat=rotvec_to_rotmat2(rotvec);

rlu_corr=b\rotmat*b0;

% Now test:
[alatt_out,angdeg_out,rotmat_out]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0);

if max(abs(alatt_out(:)-alatt(:)))>eps, assertTrue(false,'Lattice parameters not recovered'), end
if max(abs(angdeg_out(:)-angdeg(:)))>eps, assertTrue(false,'Lattice angless not recovered'), end
if max(abs(rotmat_out(:)-rotmat(:)))>eps, assertTrue(false,'Rotation matrix not recovered'), end
