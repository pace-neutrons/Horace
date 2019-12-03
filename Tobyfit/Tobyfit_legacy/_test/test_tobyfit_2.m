function res=test_tobyfit_2 (varargin)
% Test Tobyfit moderator refinement
%
%   >> test_tobyfit_2           % Use previously saved sqw input data file
%   >> test_tobyfit_2 ('save')  % Save test files to disk

if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognized option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end

%% --------------------------------------------------------------------------------------
% Setup
% --------------------------------------------------------------------------------------
dir_in=fileparts(which(mfilename));
dir_out=tmp_dir;

efix=45;
emode=1;
en=-5:0.1:5;
par_file=fullfile(dir_in,'9cards_4_4to1.par');
sqw_file=fullfile(dir_out,'tobyfit_refine_moderator.sqw');

alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi=0:1:60;
omega=0; dpsi=2; gl=3; gs=-3;

sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02]);


%% --------------------------------------------------------------------------------------
% Creation of test sqw file
% --------------------------------------------------------------------------------------
if save_output
    fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
else
    if ~exist(sqw_file,'file')
        error('Input sqw files for tests does not exist')
    end
end


%% --------------------------------------------------------------------------------------
% Create single cuts
% --------------------------------------------------------------------------------------
% Short cut along [1,1,0]
% -----------------------
proj.u=[1,1,0];
proj.v=[0,0,1];

w1=cut_sqw(sqw_file,proj,[0.4,0.5],[0.8,0.9],[-0.05,0.05],[-6,0,6]);
w1=set_sample_and_inst(w1,sample,@maps_instrument,'-efix',300,'S');

w2=cut_sqw(sqw_file,proj,[-0.3,-0.2],[-1,-0.9],[-0.05,0.05],[-6,0,6]);
w2=set_sample_and_inst(w2,sample,@maps_instrument,'-efix',300,'S');


%% --------------------------------------------------------------------------------------
% Tobyfit simulations to act as data for fitting
% --------------------------------------------------------------------------------------

amp=2;  en0=0;   fwhh=0.25;

% Tobyfit simulation
w1=tobyfit(w1,@testfunc_sqw_van,[amp,en0,fwhh],'eval','mc_npoints',10);
w2=tobyfit(w2,@testfunc_sqw_van,[amp,en0,fwhh],'eval','mc_npoints',10);

w1=noisify(w1,0.3);
w2=noisify(w2,0.3);


%% --------------------------------------------------------------------------------------
% Fit single cuts
% --------------------------------------------------------------------------------------
pulse=w2.header{1}.instrument.moderator.pulse_model;
par=w2.header{1}.instrument.moderator.pp;

w1_sim=tobyfit(w1,@testfunc_sqw_van,[amp,en0,fwhh],[1,1,0],'eval','mc_npoints',10);

% --------------------------------------------------------------------------------------
% First fit
mod_opts=tobyfit_refine_moderator_options(pulse,par,[1,0,0]);

% The following should look the same as w1_sim
wtmp=tobyfit(w1,@testfunc_sqw_van,[amp,en0,fwhh],[1,1,0],'eval','mc_npoints',10,'refine_mod',mod_opts);

% Now fit
[w1_fit1,fp,ok,mess,rlucorr,fitmod]=tobyfit(w1,@testfunc_sqw_van,[amp,en0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts,'list',2);


% --------------------------------------------------------------------------------------
% Do a fit with significantly different starting parameters
amp_0=3;  en0_0=0.5;
mod_opts_0=tobyfit_refine_moderator_options(pulse,1.5*par,[1,0,0]);

wtmp=tobyfit(w1,@testfunc_sqw_van,[amp_0,en0_0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts_0,'list',2,'eval');

[w1_fit2,fp,ok,mess,rlucorr,fitmod]=tobyfit(w1,@testfunc_sqw_van,[amp_0,en0_0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts_0,'list',2);


% --------------------------------------------------------------------------------------
% Do a multiple fit with significantly different starting parameters
amp_0=3;  en0_0=0.5;
const=0; grad=0;
mod_opts_0=tobyfit_refine_moderator_options(pulse,1.5*par,[1,0,0]);


[warr_fit1,fp,ok,mess,rlucorr,fitmod]=tobyfit([w1,w2],@testfunc_sqw_van,[amp_0,en0_0,fwhh],[1,1,0],...
                                                      @testfunc_bkgd,[const,grad],...
                                                      'local_fore','mc_npoints',10,'refine_mod',mod_opts_0,'list',2);
