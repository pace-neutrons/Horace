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

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu)

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[92,88,91])

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90])

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90],'fix_ang')


% Introduce random noise
rlu0=[1,0,0; 0,1,0; 0,0,1];
lattice0=[5,5,5,90,90,90];
rotvec=[pi/2,0,0];
ang_dev=0.02;
rad_dev=0.005;
rlu = make_rlu(rlu0, lattice0, lattice0, rotvec, ang_dev, rad_dev);

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu,'fix_ang')

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90],'fix_ang')

[rotmat,alatt_fit,angdeg_fit,rlu_corr] = refine_crystal_orientation(rlu0,lattice0(1:3),lattice0(4:6),rlu,[5.1,5.2,5.3],[90,90,90],'free_alatt',[1,0,1])




