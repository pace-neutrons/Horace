function test_change_crystal_1a
% Test crystal refinement functions change_crytstal and refine_crystal
%
%   >> test_refinement           % Use previously saved sqw input data file
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% -----------------------------------------------------------------------------
% Add common functions folder to path, and get location of common data
addpath(fullfile(fileparts(which('horace_init')),'_test','common_functions'))
common_data_dir=fullfile(fileparts(which('horace_init')),'_test','common_data');
% -----------------------------------------------------------------------------

dir_out=tempdir;

sim_sqw_file=fullfile(dir_out,'test_change_crystal_1sima.sqw');           % output file for simulation in reference lattice
sim_sqw_file_corr=fullfile(dir_out,'test_change_crystal_1sima_corr.sqw'); % output file for correction


[nxs_file,psi,alatt,angdeg,u,v] =  build_test_source_file(sim_sqw_file,common_data_dir,dir_out);


% Fit Bragg peak positions
% ------------------------
proj.u=[1,0,0];
proj.v=[0,1,0];

%bp=[0,-1,-1; 0,-1,0; 1,2,0; 2,3,0; 0,-1,1;0,0,1];
bp=[0,-1,0; 1,2,0; 0,-1,1;0,0,1];
half_len=0.5; half_thick=0.25; bin_width=0.025;

[rlu_real,width,wcut,wpeak]=bragg_positions(sim_sqw_file, bp, 1.5, 0.02, 0.4, 1.5, 0.02, 0.4, 2, 'gauss');
%[rlu0,width,wcut,wpeak]=bragg_positions(read_sqw(sim_sqw_file), proj, rlu, half_len, half_thick, bin_width);
%bragg_positions_view(wcut,wpeak)


% Get correction matrix from the 5 peak positions:
% ------------------------------------------------
[rlu_corr,alatt1,angdeg1,rotmat_fit] = refine_crystal(rlu_real, alatt, angdeg, bp,'fix_angdeg');



% Apply to a copy of the sqw object to see that the alignment is now OK
% ---------------------------------------------------------------------
copyfile(sim_sqw_file,sim_sqw_file_corr)
change_crystal_sqw(sim_sqw_file_corr,rlu_corr)
rlu0_corr=get_bragg_positions(read_sqw(sim_sqw_file_corr), proj, bp, half_len, half_thick, bin_width);

if max(abs(rlu0_corr(:)-bp(:)))>half_thick
    assertTrue(false,'Problem in refinement of crystal orientation and lattice parameters')
end
[alatt_c, angdeg_c, dpsi_deg, gl_deg, gs_deg] = ...
    crystal_pars_correct (u, v, alatt, alatt, 0, 0, 0, 0, rlu_corr);

cleanup_obj0=onCleanup(@()test_change_crystal_1_cleanup(nxs_file));
cleanup_obj=onCleanup(@()test_change_crystal_1_cleanup({sim_sqw_file,sim_sqw_file_corr}));



function test_change_crystal_1_cleanup(sqw_files)

ws = warning('off','MATLAB:DELETE:Permission');

% Delete temporary sqw files
for i=1:numel(sqw_files)
    try
        delete(sqw_files{i})
    catch
    end
end
warning(ws);

function  [nxs_file,psi,alatt,angdeg_true,u,v] = build_test_source_file(sim_sqw_file,common_data_dir,dir_out)
% generate shifted sqw file
%
% Data for creation of test sqw file
% ----------------------------------
efix=45;
emode=1;
en=-0.75:0.5:0.75;
par_file=fullfile(common_data_dir,'9cards_4_4to1.par');

% Parameters for generation of reference sqw file
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
psi=0:2:10;
omega=0; dpsi=2; gl=3; gs=-3;

% Parameters of the true lattice
alatt_true=[5,5,5];
angdeg_true=[90,90,90];
qfwhh=0.1;                  % Spread of Bragg peaks
efwhh=1;                    % Energy width of Bragg peaks
rotvec=[0,0,0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice


% Create sqw file for refinement testing
% --------------------------------------
urange = calc_sqw_urange (efix, emode, en(1), en(end), par_file, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

nxs_file=cell(size(psi));
for i=1:numel(psi)
    
    nxs_file{i}=fullfile(dir_out,['dummy_test_change_crystal_1a_',num2str(i),'.nxspe']);
    if ~(exist(nxs_file{i},'file')==2)
        sqw_obj = fake_sqw (en, par_file, '', efix, emode, alatt, angdeg,...
            u, v, psi(i), omega, dpsi, gl, gs, [1,1,1,1], urange);
        % Simulate cross-section on every the sqw file: place blobs at Bragg positions of the true lattice
        sqw_obj=sqw_eval(sqw_obj{1},@make_bragg_blobs,{[qfwhh,efwhh],[alatt,angdeg],[alatt_true,angdeg_true],rotvec});
        % mainly to propagate errors as sqw_eval nullified errors?
        npix = size(sqw_obj.data.pix,2);
        sqw_obj.data.pix(9,:) = ones(1,npix);
        sqw_obj=recompute_bin_data_tester(sqw_obj);
        % convert to nxspe (instrument view)
        rdo = rundatah(sqw_obj);
        rdo.saveNXSPE(nxs_file{i});
    end
end



if ~(exist(sim_sqw_file,'file')==2)
    gen_sqw (nxs_file, '', sim_sqw_file, efix, emode, alatt, angdeg,...
        u, v, psi, 0, 0, 0, 0);
end




