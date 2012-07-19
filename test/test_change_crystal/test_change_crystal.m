function test_main (varargin)
% Test crystal refinement functions change_crytstal and refine_crystal
%
%   >> test_refinement           % Use previously saved sqw input data file
%   >> test_refinement ('save')  % Save test file to  fullfile(tempdir,'sim.sqw')
%
% Reads IX_dataset_1d and IX_dataset_2d from .mat file as input to the tests

dir_in=fileparts(which(mfilename));
dir_out=tempdir;
sim_sqw_file=fullfile(dir_out,'sim.sqw');           % output file for simulation in reference lattice
sim_sqw_file_corr=fullfile(dir_out,'sim_corr.sqw'); % output file for correction

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
u=[1,0,0];
v=[0,1,0];
psi=0:1:90;
omega=0; dpsi=2; gl=3; gs=-3;

% Parameters of the true lattice
alatt_true=[5.5,5.5,5.5];
angdeg_true=[90,90,90];
qfwhh=0.1;                  % Spread of Bragg peaks 
rotvec=[10,10,0]*(pi/180);  % orientation of the true lattice w.r.t reference lattice



%% Create sqw file for refinement testing
if save_output
    urange = calc_sqw_urange (efix, emode, en(1), en(end), par_file, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
    
    sqw_file=cell(size(psi));
    for i=1:numel(psi)
        sqw_file{i}=fullfile(dir_out,['dummy_',num2str(i),'.sqw']);
        fake_sqw (en, par_file, sqw_file{i}, efix, emode, alatt, angdeg,...
            u, v, psi(i), omega, dpsi, gl, gs, [1,1,1,1], urange);
    end
    
    % Simulate cross-section on all the sqw files: place blobs at Bragg positions of the true lattice
    efwhh=1;
    for i=1:numel(psi)
        wtmp=read_horace(sqw_file{i});
        wtmp=sqw_eval(wtmp,@make_bragg_blobs,{[qfwhh,efwhh],[alatt,angdeg],[alatt_true,angdeg_true],rotvec});
        save(wtmp,sqw_file{i});
    end
    
    % Combine the sqw files
    write_nsqw_to_sqw(sqw_file,sim_sqw_file);
    
    % Delete temporary sqw files
    for i=1:numel(psi)
        delete(sqw_file{i})
    end
    
else
    if ~exist(sim_sqw_file,'file')
        error('Input sqw file for tests does not exist')
    end
end

%% Fit Bragg peak positions
% Should get approximately: rlu0=[1.052,-0.142,0.722; 0.199,0.732,1.036; 0.158,-0.135,0.886; 0.895,0.015,-0.158; -0.015,-0.900,-0.158];
proj.u=[1,0,0];
proj.v=[0,1,0];

rlu=[1,0,1; 0,1,1; 0,0,1; 1,0,0; 0,-1,0];
half_len=0.5; half_thick=0.25; bin_width=0.025;

rlu0=get_bragg_positions(read_sqw(sim_sqw_file), proj, rlu, half_len, half_thick, bin_width);


%% From getting peak positions of 5 peaks:
[rlu_corr,alatt_fit,angdeg_fit,rotmat_fit] = refine_crystal(rlu0,alatt,angdeg,rlu,'fix_angdeg');


%% Test new sqw object
copyfile(sim_sqw_file,sim_sqw_file_corr)
change_crystal_sqw(sim_sqw_file_corr,rlu_corr)
rlu_corr=get_bragg_positions(read_sqw(sim_sqw_file_corr), proj, rlu, half_len, half_thick, bin_width);

if max(abs(rlu_corr(:)-rlu(:)))>qfwhh
    error('Problem in refinement of crystal orientation and lattice parameters')
else
    disp('Test succesfully completed')
end

%% Problems

% Sometimes the title goes missing (23/6/12):
% w2b=cut_sqw(file_to_cut,proj,[-1.5,0.025,1.5],[-1.5,0.025,1.5],[-0.5,0.5],[-Inf,Inf]);
% w2b=cut_sqw(file_to_cut,proj,[-1.5,0.025,1.5],[-1.5,0.025,1.5],[0.5,1.5],[-Inf,Inf]);
% plot(w2b)   % *** TITLE MISSING
