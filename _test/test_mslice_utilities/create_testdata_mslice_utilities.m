function create_testdata_mslice_utilities
% Create test data for testing mslice related utilities in Horace
%
%   >> create_testdata_mslice_utilities
%
% The data is created in the folder returned by the function tempdir.
%
% Author: T.G.Perring

% -----------------------------------------------------------------------------
% Add common functions folder to path, and get location of common data
addpath(fullfile(fileparts(which('horace_init')),'_test','common_functions'))
common_data_dir=fullfile(fileparts(which('horace_init')),'_test','common_data');
% -----------------------------------------------------------------------------

output_file=fullfile(tempdir,'testdata_mslice_utilities');


% Create sqw file and cuts
% ------------------------
en=(10:1:190)+0.5;
par_file=fullfile(common_data_dir,'MAPS_A1_and_A2_first_pack.par');
sqw_file=fullfile(tempdir,'test_mslice_horace.sqw');
efix=200;
emode=1;
alatt=[5,5,4.58];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,1];
psi=-15;
omega=0; dpsi=0; gl=0; gs=0;
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

% Simulate with a simple dispersion
w=read_sqw(sqw_file);
pars=[10,50,5];
fwhh=10;
wcalc=disp2sqw_eval(w,@disp_1D_hafm,pars,fwhh);
save(wcalc,sqw_file);

% Take 1D and 2D cuts
proj.u=[0,0,1];
proj.v=[0,1,0];

w1q=cut_sqw(wcalc,proj,[0.3,0.04,0.7],[0.2,0.4],[-Inf,Inf],[30,35]);    % 1D cut along a q axis
save(w1q,fullfile(tempdir,'w1q.sqw'));

w1e=cut_sqw(wcalc,proj,[0.4,0.5],[0.2,0.4],[-Inf,Inf],[15,0,60]);       % 1D cut along energy axis
save(w1e,fullfile(tempdir,'w1e.sqw'));

w2qq=cut_sqw(wcalc,proj,[-0.82,0.04,1.26],[-0.9,0.04,1.3],[-Inf,Inf],[30,35]);  % 2D plane in Q
save(w2qq,fullfile(tempdir,'w2qq.sqw'));

w2qe=cut_sqw(wcalc,proj,[0.3,0.04,0.7],[0.2,0.4],[-Inf,Inf],[15,0,60]); % 2D plane in QE
save(w2qe,fullfile(tempdir,'w2qe.sqw'));


% Create .slc and .cut files
s1q=to_cut(w1q);
s1e=to_cut(w1e);
s2qq=to_slice(w2qq);
s2qe=to_slice(w2qe);

save(s1q,fullfile(tempdir,'s1q.cut'));
save(s1e,fullfile(tempdir,'s1e.cut'));
save(s2qq,fullfile(tempdir,'s2qq.slc'));
save(s2qe,fullfile(tempdir,'s2qe.slc'));

try
    delete(sqw_file)
catch
    disp('Unable to delete temporary file(s)')
end

% -----------------------------------------------------------------------------
% Create zip file with cuts and slices
% -----------------------------------------------------------------------------
files={fullfile(tempdir,'w1q.sqw'),fullfile(tempdir,'w1e.sqw'),...
       fullfile(tempdir,'w2qq.sqw'),fullfile(tempdir,'w2qe.sqw'),...
       fullfile(tempdir,'s1q.cut'),fullfile(tempdir,'s1e.cut'),...
       fullfile(tempdir,'s2qq.slc'),fullfile(tempdir,'s2qe.slc')};

zip(output_file,files);


%------------------------------------------------------------------------------------------------------
% We *MUST* do some checks with the mslice cuts below - seems to agree OK, so save the cuts and slices
%------------------------------------------------------------------------------------------------------

% Create spe file and equivalent cuts in mslice
% ---------------------------------------------
scalc=spe(wcalc);
spe_file=fullfile(tempdir,'test_mslice_horace.spe');
save(scalc,spe_file)

phx_file=fullfile(common_data_dir,'MAPS_A1_and_A2_first_pack.phx');

% Run mslice to generate equivalent cuts
% In general the cuts differ by a few pixels from those taken in Horace. This is because mslice uses 2.07
% instead of 2.07214 for the conversion E(meV)=2.07214*k(Ang^-1)^2, I think.
% There is also a difference that comes from the detector group number in mslice being set to 1:n
mslice_start
mslice_load_data (spe_file, phx_file, efix, emode, 'S(Q,w)', '')
mslice_sample(alatt,angdeg,u,v,psi)
mslice_calc_proj([0,0,1],[0,1,0],[0,0,0,1],'l','k','E')

mslice_2d([-0.82,0.04,1.26],[-0.9,0.04,1.3],[30,35],'range',[0,2],'plot',0,'file',fullfile(tempdir,'ms_s2qq.slc'))
mslice_2d([0.3,0.04,0.7],[0.2,0.4],[15,0,60],'range',[0,2],'plot',0,'file',fullfile(tempdir,'ms_s2qe.slc'))

mslice_1d([0.3,0.04,0.7],[0.2,0.4],[30,35],'range',[0,3],'plot','file',fullfile(tempdir,'ms_s1q.cut'));
mslice_1d([0.4,0.5],[0.2,0.4],[15,0,60],'range',[0,3],'plot','file',fullfile(tempdir,'ms_s1e.cut'));

disp('==========================================================================')
disp('  YOU **MUST** CHECK THAT MSLICE AND HORACE CUTS ARE (ALMOST) IDENTICAL')
disp('==========================================================================')
