% Example script to fit Gd2Pt2O7 SpinW model to two 1d cuts through the
% data.
%
% ============
% Russell Ewings - 20/5/2020
% Ross Stewart - 13/07/2022
%

%% Fitting with Spinw -  2 simultaneous 1d cuts

sqw_gpo = 'gpo_1p6.sqw';  % 1.6 meV LET data - powder averaged
Ei = 1.6;                 % incident energy
dE = 0.03;                % energy resolution (average) from PyChop
dQ = 0.01;                % Q-resolution estimate
s = rng(1);               % random number seed, so that you get the same result each time

% Fitting parameters - Model is 3 Js on the pyrochlore lattice + dipolar +
% anisotropy (fixed)
scalefac=0.064;            % intensity scale factor
J = [4.92,0.11,0.01,0.0];  % exchange guess values
D   = 3.52;                % single ion anisotropy
muR = 1.4;                 % sample self attenuation
bg  = 0.14;                % background

%Take first 1d cut along the energy axis
Qrange1=[0.2,0.3];        %note down the Q range for integration, as we need to pass this to the simulating / fitting function
gpo_cut_Q1=cut_sqw(sqw_gpo,Qrange1,[0.1,0.005,0.63],'-nopix');
%check for NaNs in cut
ok = ~isnan(gpo_cut_Q1.s);
%create IX dataset (is this really necessary)
gpo_IX1d_Q1=IX_dataset_1d(gpo_cut_Q1.p{1}(ok),gpo_cut_Q1.s(ok),sqrt(gpo_cut_Q1.e(ok)));

%Take a second 1d cut along the energy axis
Qrange2=[0.4,0.5];        %note down the Q range for integration, as we need to pass this to the simulating / fitting function
gpo_cut_Q2=cut_sqw(sqw_gpo,Qrange2,[0.1,0.005,0.63],'-nopix');
%check for NaNs in cut
ok = ~isnan(gpo_cut_Q2.s);
%create IX dataset (is this really necessary)
gpo_IX1d_Q2=IX_dataset_1d(gpo_cut_Q2.p{1}(ok),gpo_cut_Q2.s(ok),sqrt(gpo_cut_Q2.e(ok)));

% run multifit on both datasets
gpo_fit = multifit([gpo_IX1d_Q1,gpo_IX1d_Q2]);
gpo_fit = gpo_fit.set_mask('remove',[0.43,0.5]);
gpo_fit = gpo_fit.set_local_foreground;
gpo_fit = gpo_fit.set_fun(@spinw_gpo_1dfit);
gpo_fit = gpo_fit.set_pin({{[scalefac,J,D,muR,bg],Qrange1,Ei,dE,dQ,s},...
                           {[scalefac,J,D,muR,bg],Qrange2,Ei,dE,dQ,s}});
gpo_fit = gpo_fit.set_free([0,1,1,1,0,0,1,0]);
gpo_fit = gpo_fit.set_bind({{2,[2,1]},{3,[3,1]},{4,[4,1]},{7,[7,1]}});
gpo_fit = gpo_fit.set_options('list',1);

[wfit,fitdata] = gpo_fit.fit();

% Plot data with fit over the top ("ploc" means plot line over current in 
% Horace)
acolor black
plot(gpo_cut_Q1)
acolor red
ploc(wfit(1)); keep_figure
acolor black
plot(gpo_cut_Q2)
acolor red
ploc(wfit(2)); keep_figure

