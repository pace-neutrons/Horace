function test_tobyfit_refine_crystal (varargin)
% Test crystal refinement option in Tobyfit
%
%   >> test_refinement           % Use previously saved sqw input data file
%   >> test_refinement ('save')  % Save test files to disk
%
% Reads IX_dataset_1d and IX_dataset_2d from .mat file as input to the tests

dir_in=fileparts(which(mfilename));
dir_out=tempdir;
sqw_file_nores=fullfile(dir_out,'tobyfit_refine_crystal_nores.sqw');           % output file for simulation in reference lattice
sqw_file_nores_corr=fullfile(dir_out,'tobyfit_refine_crystal_nores_corr.sqw'); % output file for correction

sqw_file_res=fullfile(dir_out,'tobyfit_refine_crystal.sqw');           % output file for simulation in reference lattice
sqw_file_res_corr=fullfile(dir_out,'tobyfit_refine_crystal_corr.sqw'); % output file for correction

if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end


%% Data for creation of test sqw file
efix=45;
emode=1;
en=-0.75:0.5:0.75;
par_file=fullfile(dir_in,'9cards_4_4to1.par');

% Parameters for generation of reference sqw file
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi=0:1:90;
omega=0; dpsi=2; gl=3; gs=-3;

% Parameters of the true lattice
alatt_true=[4.75,4.75,4.75];
angdeg_true=[90,90,90];
amp=2;
qfwhh=0.1;                  % Spread of Bragg peaks 
efwhh=1;                    % Energy width of Bragg peaks
rotvec=[1,-2,-2]*(pi/180);  % orientation of the true lattice w.r.t reference lattice

% Instrument setup
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);


%% Create sqw file for refinement testing
if save_output
    % Create sqw file
    fake_sqw (en, par_file, sqw_file_nores, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
    
    % Simulate Bragg blobs
    wtmp=read_horace(sqw_file_nores);
    wtmp=sqw_eval(wtmp,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg],[alatt_true,angdeg_true],rotvec});
    wtmp=set_sample_and_inst(wtmp,sample,@maps_instrument,'-efix',300,'S');
    wtmp=noisify(wtmp,0.01);
    save(wtmp,sqw_file_nores);
    
    % Simulate with Tobyfit broadening (needs 16GB RAM; simuolation takes c. 200 seconds on TGP's Dell XPS15z from March 2012)
    tic
    wsim=tobyfit(wtmp,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg],[alatt_true,angdeg_true],rotvec},'eval');
    toc
    wsim=noisify(wsim,0.01);
    save(wsim,sqw_file_res);
    
    clear wtmp wsim
    
else
    if ~exist(sqw_file_res,'file')||~exist(sqw_file_nores,'file')
        error('Input sqw files for tests does not exist')
    end
end

%% Refine crystal using bragg_positions

% Fit Bragg peak positions
rlu=[1,1,0; 1,1,1; 0,0,-1; 2,2,0];
radial_cut_length=0.4; radial_bin_width=0.005; radial_thickness=0.15;
trans_cut_length=15; trans_bin_width=0.5; trans_thickness=5;
opt='Gaussian';

[rlu0,width,wcut,wpeak]=bragg_positions(read_sqw(sqw_file_res), rlu, radial_cut_length, radial_bin_width, radial_thickness,...
                                                            trans_cut_length, trans_bin_width, trans_thickness, opt);
% bragg_positions_view(wcut,wpeak)  % for manual checking

% Get rlu_corr from peak positions:
[rlu_corr,alatt_fit,angdeg_fit,rotmat_fit,distance,rotangle] = refine_crystal(rlu0,alatt,angdeg,rlu,'fix_angdeg','fix_alatt_ratio');

% Test new sqw object
copyfile(sqw_file_res,sqw_file_res_corr)
change_crystal_sqw(sqw_file_res_corr,rlu_corr)
[rlu0_corr,width,wcut,wpeak]=bragg_positions(read_sqw(sqw_file_res_corr), rlu, radial_cut_length, radial_bin_width, radial_thickness,...
                                                            trans_cut_length, trans_bin_width, trans_thickness, opt);
if max(abs(rlu0_corr(:)-rlu(:)))>qfwhh
    error('Problem in refinement of crystal orientation and lattice parameters')
else    % delete file
    try
        delete(sqw_file_res_corr)
    catch
        disp(['Unable to delete temporary file: ',sqw_file_res_corr])
    end
end


%% Refine crystal using Tobyfit
proj.u=[1,1,0];
proj.v=[0,0,1];

w110_r=cut_sqw(sqw_file_res,proj,[0.8,0.01,1.2],[-0.2,0.2],[-0.15,0.15],[-Inf,Inf]);
w110_t=cut_sqw(sqw_file_res,proj,[0.85,1.15],[-0.2,0.01,0.2],[-0.15,0.15],[-Inf,Inf]);
w110_v=cut_sqw(sqw_file_res,proj,[0.85,1.15],[-0.2,0.2],[-0.15,0.01,0.2],[-Inf,Inf]);

w00m1_r=cut_sqw(sqw_file_res,proj,[-0.15,0.15],   [-1.3,0.01,-0.7],[-0.15,0.15],   [-Inf,Inf]);
w00m1_t=cut_sqw(sqw_file_res,proj,[-0.2,0.01,0.2],[-1.2,-0.8],     [-0.15,0.15],   [-Inf,Inf]);
w00m1_v=cut_sqw(sqw_file_res,proj,[-0.15,0.15],   [-1.2,-0.8],     [-0.2,0.01,0.2],[-Inf,Inf]);

w=[w110_r,w110_t,w110_v;w00m1_r,w00m1_t,w00m1_v];

xtal_opts = tobyfit_refine_crystal_options('fix_angdeg','fix_alatt_ratio');

% Fit a global function
[wf_tf,fitpar_tf,ok,mess,rlu_corr_tf]=tobyfit(w,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]},[1,1,0],...
    'refine_crystal',xtal_opts,'list',3,'mc_npoints',2);
if ~ok
    disp(mess)
end
if any(abs(rlu_corr_tf(:)-rlu_corr(:))>0.004)
    error('Bragg peak crystal refinement and Tobyfit crystal refinement are not the same')
else
    disp('*******************************************************************************')
    disp('  1 of 2: Bragg peak crystal refinement and Tobyfit crystal refinement agree')
    disp('*******************************************************************************')
end

% Fit local foreground functions (independent widths)
[wf_tf,fitpar_tf,ok,mess,rlu_corr_tf]=tobyfit(w,@make_bragg_blobs,{{[amp,qfwhh,efwhh],[alatt,angdeg]}},[1,1,0],...
    'refine_crystal',xtal_opts,'list',3,'local_fore','mc_npoints',2);
if ~ok
    disp(mess)
end
if any(abs(rlu_corr_tf(:)-rlu_corr(:))>0.004)
    error('Bragg peak crystal refinement and Tobyfit crystal refinement are not the same')
else
    disp('*******************************************************************************')
    disp('  2 of 2: Bragg peak crystal refinement and Tobyfit crystal refinement agree')
    disp('*******************************************************************************')
end

