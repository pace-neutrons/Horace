%% Some tests that refine_crystal is doing its job properly

% function test_refine_orientation
rlu0=[1,0,0; 0,1,0; 0,0,1];
lattice0=[5,5,5,90,90,90];
lattice=[5,5,5,90,90,90];
rotvec=[0,0,0];
ang_dev=0;
rad_dev=0;
rlu = make_rlu(rlu0, lattice0, lattice, rotvec, ang_dev, rad_dev)

% Three orthogonal vectors
% ------------------------
% Case where exact fit

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu)

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[92,88,91])

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90])

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90],'fix_ang')


% Introduce random noise
rlu0=[1,0,0; 0,1,0; 0,0,1];
lattice0=[5,5,5,90,90,90];
rotvec=[pi/2,0,0];
ang_dev=0.02;
rad_dev=0.005;
rlu = make_rlu(rlu0, lattice0, lattice0, rotvec, ang_dev, rad_dev);

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu,'fix_ang')

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90],'fix_ang')

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90],'free_alatt',[1,0,1])




