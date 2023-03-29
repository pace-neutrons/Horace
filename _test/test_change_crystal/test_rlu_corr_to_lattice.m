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

assertElementsAlmostEqual(alatt_out,alatt,'absolute',eps, ...
    'Lattice parameters not recovered')
assertElementsAlmostEqual(angdeg_out,angdeg,'absolute',eps, ...
    'Lattice angles not recovered')
assertElementsAlmostEqual(rotmat_out,rotmat,'absolute',eps, ...
    'Rotation matrix not recovered')
