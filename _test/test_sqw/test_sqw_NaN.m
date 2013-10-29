function test_sqw_NaN
% Pixels from detectors that are masked out in the spe file shold not appear
% in the sqw file. Test that this is correctly handled by gen_sqw.
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Data
spe_file=fullfile(tempdir,'test_sqw_NaN.spe');
ndet=32;
par_file='2m_w.par';
sqw_file=fullfile(tempdir,'test_sqw_NaN.sqw');

efix=35;
ebins=5:0.5:10;
emode=1;
alatt=[5,6,7];
angdeg=[80,92,103];
u=[1,1,0];
v=[0,0,3];
psi=76;
omega=0; dpsi=0; gs=0; gl=0;

msk=[1,2,10,11,12,21,32];

% Create spe file
[spe_path,spe_name,spe_ext]=fileparts(spe_file);
fake_spe (ndet,ebins,[spe_name,spe_ext],spe_path,'mask',msk);

% Create sqw file
grid=[3,3,3,3];     % to force non-monotonic arrays in the pix array
gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, grid)

% Check that the masked detectors are correctly eliminated when create sqw file
w=read_sqw(sqw_file);
idet=[unique(w.data.pix(6,:)),msk];     % list of detectors including those masked
if ~isequal(sort(idet),1:ndet)
    assertTrue(false,'Problem with handling masked detectors in creation of sqw file')
end

% Check sqw->spe converter
spe_ref=read_spe(spe_file);
spe_new=spe(w);
if ~equal_to_tol(spe_new,spe_ref,-5e-7,'min_denominator',1,'ignore_str',1)
    assertTrue(false,'original spe file and sqw->spe conversion are different')
end

% Success announcement
% --------------------
try
    delete(spe_file)
    delete(sqw_file)
catch
    disp('Unable to delete temporary file(s)')
end
banner_to_screen([mfilename,': Test(s) passed (matches are within requested tolerances)'],'bot')
