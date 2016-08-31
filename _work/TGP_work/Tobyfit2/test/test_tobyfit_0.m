%% ================================================================================================
% Setup 
% -----
data_source='E:\data\RbMnF3\sqw\rbmnf3_ref.sqw';                   % output sqw file

proj.u=[1,1,0];
proj.v=[0,0,1];



%% ================================================================================================
% Tobyfit
% ----------------------------------------

% Set the sample and instrument in the master sqw file
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

set_sample_horace(data_source,sample)
set_instrument_horace(data_source,@maps_instrument,'-efix',300,'S')



% Refine the moderator lineswidth
% ===============================
% Make sure we find a good region to get incoherent scattering
w2inc=cut_sqw(data_source,proj,[-1,0.01,1],[-0.5,0.01,1.5],[-0.05,0.05],[-2,2],'-nopix');
plot(smooth(w2inc))
lz 0 100

% Make a 1D cut that avoids Bragg peaks and aluminium powder lines
w1inc=cut_sqw(data_source,proj,[0.3,0.5],[0,0.2],[-0.1,0.1],[-3,0.1,3]);  % better stats
plot(w1inc)

% Get the moderator pulse name and parameters
[efix,emode,ok]=get_efix(w1inc);
if ~ok, error(mess), end    % check ei are all the same (within some small tolerance)

% Get moderator pulse name and parameters
[pulse_model,pp,ok]=get_mod_pulse(w1inc);
if ~ok, error(mess), end    % check name and parameters are all the same (within some small tolerance)


% Tobyfitting proper
% ------------------
% We can see that the model is 'ikcarp' and it has three parameters; we are only going to refine the first one
mod_opts=tobyfit_refine_moderator_options([1,0,0]);   % take default moderator parameters as starting point

% Could equally well have set the options explicity from the previously extracted values, or 
% a different model altogether
mod_opts=tobyfit_refine_moderator_options(pulse_model,pp,[1,0,0]);

% Check we have good starting parameters
amp=100;  en0=0;   fwhh=0.25;
wtmp=tobyfit(w1inc,@van_sqw,[amp,en0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts,'eval');
acolor b; dd(w1inc); acolor r; pl(wtmp)

% Good choice of parameters, so start the fit
[w1fit,pfit,ok,mess,pmodel,ppfit]=tobyfit(w1inc,@van_sqw,[amp,en0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts,'list',2);
acolor b; dd(w1inc); acolor r; pl(w1fit)

% Happy with the fit (ppfit(1)=10.25 +/- 0.26), so redefine the moderator parameters in the main sqw file
set_mod_pulse_horace(data_source,pmodel,ppfit);


















% Tobyfitting proper
% ==================
% Refine the moderator lineswidth
% --------------------------------
% Make sure we find a good region to get incoherent scattering
w2inc=cut_sqw(data_source,proj,[-1,0.01,1],[-0.5,0.01,1.5],[-0.05,0.05],[-2,2],'-nopix');
plot(w2inc)

winc_1=cut_sqw(data_source,proj,[0.45,0.55],[-0.05,0.05],[-0.05,0.05],[-2,0.1,2]);
winc_2=cut_sqw(data_source,proj,[0.3,0.5],[0,0.2],[-0.1,0.1],[-2,0.1,2]);  % better stats
winc_1=set_sample_and_inst(winc_1,sample,@maps_instrument,'-efix',300,'S');
winc_2=set_sample_and_inst(winc_2,sample,@maps_instrument,'-efix',300,'S');

% First fit
% - - - - -
mod_opts=tobyfit_refine_moderator_options([1,0,0]);   % take default moderator parameters as starting point

% Check we have good starting parameters
amp=100;  en0=0;   fwhh=0.25;
wtmp=tobyfit(winc_2,@van_sqw,[amp,en0,fwhh],[1,1,0],'eval','mc_npoints',10,'refine_mod',mod_opts);
acolor b; dd(winc_2); acolor r; pl(wtmp)

% Now fit: get linewidth of tauf = 10.09 +/- 0.24 mms (cf starting value of 11.84 mms)
[winc_1_fit1,fp,ok,mess,rlucorr,fitmod]=tobyfit(winc_1,@van_sqw,[amp,en0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts,'list',2);
acolor b; dd(winc_1); acolor r; pl(winc_1_fit1)

[winc_2_fit1,pinc_2_fit1,ok,mess,rlucorr,fitmod]=tobyfit(winc_2,@van_sqw,[amp,en0,fwhh],[1,1,0],'mc_npoints',10,'refine_mod',mod_opts,'list',2);
acolor b; dd(winc_2); acolor r; pl(winc_2_fit1)

pp_fit=[10.12,0,0];

% Transfer refined moderator linewidth to sample runs
% ---------------------------------------------------
% *** Need to find a neater way to do this!
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
w1_0=set_sample_and_inst(w1_0,sample,@maps_instrument,'-efix',300,'S');
w1_2=set_sample_and_inst(w1_2,sample,@maps_instrument,'-efix',300,'S');
w1_4=set_sample_and_inst(w1_4,sample,@maps_instrument,'-efix',300,'S');
w1e_2=set_sample_and_inst(w1e_2,sample,@maps_instrument,'-efix',300,'S');
w1e_3=set_sample_and_inst(w1e_3,sample,@maps_instrument,'-efix',300,'S');
w1e_4=set_sample_and_inst(w1e_4,sample,@maps_instrument,'-efix',300,'S');
w1e_5=set_sample_and_inst(w1e_5,sample,@maps_instrument,'-efix',300,'S');
w1e_6=set_sample_and_inst(w1e_6,sample,@maps_instrument,'-efix',300,'S');
for i=1:w1e_6.main_header.nfiles
    w1_0.header{i}.instrument.moderator.pp=pp_fit;
    w1_2.header{i}.instrument.moderator.pp=pp_fit;
    w1_4.header{i}.instrument.moderator.pp=pp_fit;
    w1e_2.header{i}.instrument.moderator.pp=pp_fit;
    w1e_3.header{i}.instrument.moderator.pp=pp_fit;
    w1e_4.header{i}.instrument.moderator.pp=pp_fit;
    w1e_5.header{i}.instrument.moderator.pp=pp_fit;
    w1e_6.header{i}.instrument.moderator.pp=pp_fit;
end

% Check starting parameters again: mc_points=10 is OK, from multiple overplotting
w1sim_dsho=tobyfit(w1e_6,@rbmnf3_sqw,[5000,9,0,0.3,0],[1,1,0,1,0],'mc_npoints',10,'eval');
acolor b; dd(w1e_6); acolor r; pl(w1sim_p3_dsho)

% Constant-E scan fit
% -------------------
% Now fit (need mc_npoints=50 rather than 10 to get a good result)
% Looks marvellous!
[w1e_6_fit_dsho,p1e_6_fit_dsho]=tobyfit(w1e_6,@rbmnf3_sqw,[5000,9,0,0.3,0],[1,1,0,1,0],'mc_npoints',50,'list',2);
acolor b; dd(w1e_6); acolor r; pl(w1e_6_fit_dsho)

% Essentially width==0, and strongly correlated with intensity, so fix:
% [Get SJ=8.847+/-0.014] (Intensity=5184.9)
[w1e_6_fit_dsho,p1e_6_fit_dsho]=tobyfit(w1e_6,@rbmnf3_sqw,[5000,9,0,0.03,0],[1,1,0,0,0],'mc_npoints',50,'list',2);
acolor b; dd(w1e_6); acolor r; pl(w1e_6_fit_dsho)

% Look at a constant-Q cut
% ------------------------
% [Get SJ=8.786+/-0.013]
% Looks excellent. Note slightly different J compared to 6meV const-E cut.
[w1_0_fit_dsho,p1_0_fit_dsho]=tobyfit(w1_0,@rbmnf3_sqw,[5000,9,0,0.03,0],[1,1,0,0,0],'mc_npoints',50,'list',2);
acolor b; dd(w1_0); acolor r; pl(w1_0_fit_dsho)


















