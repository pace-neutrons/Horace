function test_sqw_NaN
% Pixels from detectors that are masked out in the spe file should not appear
% in the sqw file. Test that this is correctly handled by gen_sqw.
%
% Author: T.G.Perring

banner_to_screen(mfilename)
% this configuration value is responsible for Nan to be masked
hc = hor_config;
cl_val = hc.get_data_to_store();
clObj = onCleanup(@()set(hc,cl_val));
hc.ignore_nan = true;


% Data
spe_file=fullfile(tmp_dir,'test_sqw_NaN.spe');
ndet=32;
par_file='2m_w.par';
sqw_file=fullfile(tmp_dir,'test_sqw_NaN.sqw');

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
[spe_path,spe_name]=fileparts(spe_file);
spe_name = fullfile(spe_path,[spe_name,'.nxspe']);
spe_data = dummy_spe (ndet,ebins,'mask',msk);
rd = rundata('',par_file);
rd.S=spe_data.S;
rd.ERR=spe_data.ERR;
rd.en=spe_data.en;
rd.efix = efix;
rd.saveNXSPE(spe_name);
clob = onCleanup(@()delete(spe_name,sqw_file));

% Create sqw file
grid=[3,3,3,3];     % to force non-monotonic arrays in the pix array
gen_sqw (spe_name, '', sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, grid)

% Check that the masked detectors are correctly eliminated when create sqw file
w=sqw(sqw_file);
idet=[unique(w.pix.detector_idx),msk];     % list of detectors including those masked
assertEqual(sort(idet),1:ndet,'Problem with handling masked detectors in creation of sqw file')

% Check sqw->spe converter
spe_ref=spe(spe_data); %read_spe(spe_file);
spe_new=spe(w);
% TODO:
% This is inconsistency in obtaining spe data through two different
% channels but this inconsitency may have deep meening as fitting rejects
% points with 0 error. Does it similarly ignores points with NaN in error,
% I do not know
spe_zer = spe_new.ERR==0;
spe_new.ERR(spe_zer)=nan;
%
[ok,mess]=equal_to_tol(spe_new,spe_ref,-5e-7,'min_denominator',1,'ignore_str',1);
if ~ok
    assertTrue(false,...
        ['original spe file and sqw->spe conversion are different, error: '...
        ,mess])
end

% Success announcement
% --------------------
banner_to_screen([mfilename,': Test(s) passed (matches are within requested tolerances)'],'bot')
