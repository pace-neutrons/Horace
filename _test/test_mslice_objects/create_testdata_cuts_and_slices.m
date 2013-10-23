function create_testdata_cuts_and_slices
% This function creates the test cuts and slices from spe file, and saves to file
%
%   >> create_testdata_cuts_and_slices
%
% Creates the cuts and slices from an spe file that is simulated by this routine.
% Make sure that the common test data files have been unzipped and the common
% test functions have been placed on the path.
% Saves a number of cuts and slices to another zip file in the location
% returned by the Matlab function tempdir.
%
% Author: T.G.Perring

work_dir=tempdir;
output_file=fullfile(work_dir,'testdata_cut_slice_files.zip');

% -----------------------------------------------------------------------------
% Use mslice to create some cuts and slices
% -----------------------------------------------------------------------------
spe_file=[work_dir,'test_mslice_objects.spe'];
par_file=[work_dir,'map_4to1_jul09.par'];
phx_file=[work_dir,'map_4to1_jul09.phx'];

efix=402.61;
emode=1;

alatt=[3.5128,3.5128,3.5128];   % low temperature value from literature
angdeg=[90,90,90];
u=[0.9788,1.0230,0.0205];
v=[0.0584,-0.0659,1.0029];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;

% Create an spe file
en=-30:2:380;
simulate_spe_testfunc (en, par_file, spe_file, @sqw_fcc_hfm_testfunc, [5,25,10,70,0], 0.1, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)

% Run mslice
alatt=[3.8,3.3,3.5];
angdeg=[80,83,86];
psi=-10;

mslice_start
mslice_load_data (spe_file, phx_file, efix, emode, 'S(Q,w)', '')
mslice_sample(alatt,angdeg,u,v,psi)
mslice_calc_proj([0,0,1],[1.000000000000000  -1.000000000000000  -0.074426779585827],...
    [1.000000000000000   0.768197265570294   0.236797836452993],'L','K','H')


% -----------------------------------------------------------------------------
% Some cuts:
% -----------------------------------------------------------------------------

% Close-up cut
mc_1=mslice_1d([1.5,0.05,2],[-1.02,-0.98],[0.98,1.02],'file',fullfile(work_dir,'mc_1.cut'));

% Wider cut:
mc_2=mslice_1d([-1,0.05,2],[-1.02,-0.98],[0.98,1.02],'file',fullfile(work_dir,'mc_2.cut'));

% Array of cuts
mc_3a=mslice_1d([1.6,0.05,2.1],[-1.02,-0.98],[1.02,1.04],'file',fullfile(work_dir,'mc_3a.cut'));
mc_3b=mslice_1d([1.7,0.05,2.2],[-1.02,-0.98],[1.54,1.56],'file',fullfile(work_dir,'mc_3b.cut'));
mc_3c=mslice_1d([1.8,0.05,2.3],[-1.02,-0.98],[2.06,2.08],'file',fullfile(work_dir,'mc_3c.cut'));


% -----------------------------------------------------------------------------
% Some slices:
% -----------------------------------------------------------------------------
ms_1=mslice_2d([-2.5,0.025,2.5],[-2,0.025,2],[0.98,1.02],'range',[0,0.6],'file',fullfile(work_dir,'ms_1.slc'));

% Close-up slice
ms_2=mslice_2d([-2.1,0.025,-1.9],[-1.8,0.025,-1.65],[0.98,1.02],'range',[0,0.1],'file',fullfile(work_dir,'ms_2.slc'));

% Array of slices
ms_3a=mslice_2d([0,0.025,1],[0,0.025,1],[1.02,1.04],'range',[0,0.6],'file',fullfile(work_dir,'ms_3a.slc'));
ms_3b=mslice_2d([0,0.025,1],[0,0.025,1],[1.54,1.56],'range',[0,0.6],'file',fullfile(work_dir,'ms_3b.slc'));
ms_3c=mslice_2d([0,0.025,1],[0,0.025,1],[2.06,2.08],'range',[0,0.6],'file',fullfile(work_dir,'ms_3c.slc'));


% Run mslice again to get a Q-E slice
mslice_calc_proj([1.000000000000000  -1.000000000000000  -0.074426779585827],...
    [1.000000000000000   0.768197265570294   0.236797836452993],[0,0,0,1],'K','H','E')
ms_4=mslice_2d([0,0.025,1],[0.98,1.02],0,'range',[0,0.6],'file',fullfile(work_dir,'ms_4.slc'));


% -----------------------------------------------------------------------------
% Create zip file with cuts and slices
% -----------------------------------------------------------------------------
files={fullfile(work_dir,'mc_1.cut'),fullfile(work_dir,'mc_2.cut'),...
    fullfile(work_dir,'mc_3a.cut'),fullfile(work_dir,'mc_3b.cut'),fullfile(work_dir,'mc_3c.cut'),...
    fullfile(work_dir,'ms_1.slc'),fullfile(work_dir,'ms_2.slc'),...
    fullfile(work_dir,'ms_3a.slc'),fullfile(work_dir,'ms_3b.slc'),fullfile(work_dir,'ms_3c.slc'),fullfile(work_dir,'ms_4.slc')};

zip(output_file,files);


% -----------------------------------------------------------------------------
% Delete spe file
% -----------------------------------------------------------------------------
try
    delete(spe_file)
catch
    disp([mfilename,': unable to delete temporary spe file'])
end
