function test_refine_crystal
% Some tests that refine_crystal is doing its job properly
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Case where exact fit should be possible
% ---------------------------------------
% The refinement involves a least-squares fit, so will not be exact, hence the large tolerance

rlu0=[1,0,0; 0,1,0; 0,0,1];
alatt0=[5,5,5];
angdeg0=[90,90,90];
rotvec=[0,0,0];
ang_dev=0;
rad_dev=0;
rlu = make_rlu(rlu0, [alatt0,angdeg0], [alatt0,angdeg0], rotvec, ang_dev, rad_dev);

answer=struct('rlu_corr',eye(3),'alatt',alatt0,'angdeg',angdeg0,'rotmat',eye(3));

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu);
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,1e-9);
if ~ok, assertTrue(false,mess), end

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu,[5.1,5.2,5.3],[92,88,91]);
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,1e-9);
if ~ok, assertTrue(false,mess), end

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu,[5.1,5.2,5.3],[90,90,90]);
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,1e-9);
if ~ok, assertTrue(false,mess), end

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu,[5.1,5.2,5.3],[90,90,90],'fix_ang');
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,1e-9);
if ~ok, assertTrue(false,mess), end


% Introduce random noise and a rotation
% -------------------------------------
% The random noise requis a large tolerance in the test of the fit

rlu0=[1,0,0; 0,1,0; 0,0,1];
alatt0=[5,5,5];
angdeg0=[90,90,90];
rotvec=[pi/2,0,0];
ang_dev=0.02;
rad_dev=0.005;
rlu = make_rlu(rlu0, [alatt0,angdeg0], [alatt0,angdeg0], rotvec, ang_dev, rad_dev);

answer=struct('rlu_corr',[1,0,0;0,0,1;0,-1,0],'alatt',alatt0,'angdeg',angdeg0,'rotmat',[1,0,0;0,0,1;0,-1,0]);

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu,'fix_ang');
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,-3e-2,'min_denominator',1);
if ~ok, assertTrue(false,mess), end

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu,[5.1,5.2,5.3],[90,90,90],'fix_ang');
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,-3e-2,'min_denominator',1);
if ~ok, assertTrue(false,mess), end

[rlu_corr,alatt_fit,angdeg_fit,rotmat] = refine_crystal(rlu0,alatt0,angdeg0,rlu,[5.1,5.2,5.3],[90,90,90],'free_alatt',[1,0,1]);
[ok,mess]=equal_to_tol(struct('rlu_corr',rlu_corr,'alatt',alatt_fit,'angdeg',angdeg_fit,'rotmat',rotmat),answer,-5e-2,'min_denominator',1);
if ~ok, assertTrue(false,mess), end


% OK if got to here
% -----------------
banner_to_screen([mfilename,': Test(s) passed'],'bot')
