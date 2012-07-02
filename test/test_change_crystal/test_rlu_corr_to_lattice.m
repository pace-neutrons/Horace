function test_rlu_corr_to_lattice
% This function can be used to test the private function rlu_corr_to_lattice, but only
% by changing the working directly to the location of 

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
tmp=which('rlu_corr_to_lattice','-all');
funcfolder=fileparts(tmp{1});
current_path=pwd;
try
    cd(funcfolder)
    [alatt_out,angdeg_out,rotmat_out]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0);
catch
end
cd(current_path);

if max(abs(alatt_out(:)-alatt(:)))>eps, error('Lattice parameters not recovered'), end
if max(abs(angdeg_out(:)-angdeg(:)))>eps, error('Lattice angless not recovered'), end
if max(abs(rotmat_out(:)-rotmat(:)))>eps, error('Rotation matrix not recovered'), end
