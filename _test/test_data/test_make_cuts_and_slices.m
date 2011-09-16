%% =================================================================================================================
% Make cuts and slices from mslice to compare with Horace
% --------------------------------------------------------------------

work_dir='C:\temp\';

% Unzip test_data_files.zip to C:\temp
unzip('test_spe_files.zip',work_dir)

% Create some cuts, slices, spe
spe_file=[work_dir,'EI_400-PSI_0-BASE.spe'];
sqw_file=[work_dir,'EI_400-PSI_0-BASE.sqw'];
par_file=[work_dir,'map_4to1_jul09.par'];
phx_file=[work_dir,'map_4to1_jul09.phx'];

efix=402.61;
emode=1;

alatt=[3.8,3.3,3.5];
angdeg=[80,83,86];
u=[0.9788,1.0230,0.0205];
v=[0.0584,-0.0659,1.0029];
psi=-10;
omega=0; dpsi=0; gl=0; gs=0;

% Run mslice
mslice_start
mslice_load_data (spe_file, phx_file, efix, 1, 'S(Q,w)', '')
mslice_sample(alatt,angdeg,u,v,psi)
mslice_calc_proj([0,0,1],[1.000000000000000  -1.000000000000000  -0.074426779585827],...
                         [1.000000000000000   0.768197265570294   0.236797836452993],'L','K','H')


% Some cuts:
% -----------

% Close-up cut
mc_1=mslice_1d([1.5,0.05,2],[-1.02,-0.98],[0.98,1.02],'file',fullfile(work_dir,'mc_1.cut'));

% Wider cut:
mc_2=mslice_1d([-1,0.05,2],[-1.02,-0.98],[0.98,1.02],'file',fullfile(work_dir,'mc_2.cut'));

% Array of cuts
mc_3a=mslice_1d([1.6,0.05,2.1],[-1.02,-0.98],[1.02,1.04],'file',fullfile(work_dir,'mc_3a.cut'));
mc_3b=mslice_1d([1.7,0.05,2.2],[-1.02,-0.98],[1.54,1.56],'file',fullfile(work_dir,'mc_3b.cut'));
mc_3c=mslice_1d([1.8,0.05,2.3],[-1.02,-0.98],[2.06,2.08],'file',fullfile(work_dir,'mc_3c.cut'));


% Some slices:
% ------------
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


% Create zip file with cuts and slices
% -------------------------------------
files={fullfile(work_dir,'mc_1.cut'),fullfile(work_dir,'mc_2.cut'),...
       fullfile(work_dir,'mc_3a.cut'),fullfile(work_dir,'mc_3b.cut'),fullfile(work_dir,'mc_3c.cut'),...
       fullfile(work_dir,'ms_1.slc'),fullfile(work_dir,'ms_2.slc'),...
       fullfile(work_dir,'ms_3a.slc'),fullfile(work_dir,'ms_3b.slc'),fullfile(work_dir,'ms_3c.slc'),fullfile(work_dir,'ms_4.slc')};

zip(fullfile(work_dir,'test_cut_slice_files.zip'),files);

