%% ========================================================================
%                         Simulation and Fitting
% =========================================================================

% NOTE - For help about the syntax of any command, type in Matlab:
% >> help routine_name
%  or
% >> doc routine_name
%
% EXAMPLES
% To prints in the Matlab command window the help for the gen_sqw routine
% >> help gen_sqw
%
% To displays the help for gen_sqw in the Matlab documentation window
% >> doc gen_sqw

clear variables


%% ========================================================================
%                Simulating a pre-prepared S(Q,w) function
% =========================================================================

% Create cuts and slices for use later
sqw_file = '../aaa_my_work/iron.sqw';
proj.u  = [1,1,0]; proj.v  = [-1,1,0]; proj.uoffset  = [0,0,0,0]; proj.type  = 'rrr';

% Make our usual 2d slice
my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);

% Make the array of 1d cuts previous made in the advance plotting session
energy_range = [80:20:160];
for i = 1:numel(energy_range)
    my_cuts(i) = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], ...
        [-10 10]+energy_range(i));
end

% Simulate on sqw objects
parameter_vector = [1,0,0,35,-5,15,10,0.1];
sim_slice = sqw_eval(my_slice, @sr122_xsec, parameter_vector);
sim_cut = sqw_eval(my_cuts, @sr122_xsec, parameter_vector);

% Repeat on dnd objects
sim_slice_dnd = sqw_eval(d2d(my_slice), @sr122_xsec, parameter_vector);
sim_cut_dnd = sqw_eval(d1d(my_cuts), @sr122_xsec, parameter_vector);

plot(sim_slice); keep_figure;
plot(sim_slice_dnd); keep_figure;

acolor blue
dl(sim_cut(1));
acolor red
pl(sim_cut_dnd(1));
keep_figure;

% Note the differences between simulations of notionally the same data.
% This is because dnd just takes the centre point of the integration range,
% whereas sqw takes all of the contributing detector pixels. This is
% imperative if the dispersion varies significantly in a direction
% perpendicular to your cut/slice, as it introduces broadening that the dnd
% simulation fails to capture.


%% ========================================================================
%                  Simulate a peak function with a cut
% =========================================================================
pars_in = [0.4,-0.7,0.1, 0.5,-0.2,0.1, 0.5,0.2,0.1, 0.4,0.6,0.1, 0.4,1.3,0.1];
peak_cut = func_eval(my_cuts(1), @mgauss, pars_in);

acolor black
plot(my_cuts(1))
acolor b
pl(peak_cut);


%% ========================================================================
%                 Fit a single cut with a peak function
% =========================================================================

% Allow all parameters to be free
pars_in = [0.4,-0.7,0.1, 0.5,-0.2,0.1, 0.5,0.2,0.1, 0.4,0.6,0.1, 0.4,1.3,0.1];

kk = multifit_func (my_cuts(1)-0.3);
kk = kk.set_fun (@mgauss, pars_in);
[wfit, fitdata] = kk.fit;

acolor black
plot(my_cuts(1)-0.3);
acolor red
pl(wfit);
keep_figure;


% That was not very good. Let's keep the widths of all the peaks fixed, but
% allow heights and centres to vary;
pars_in = [0.4,-0.7,0.1, 0.5,-0.2,0.1, 0.5,0.2,0.1, 0.4,0.6,0.1, 0.4,1.3,0.1];
pars_free = [1,   1,  0,   1,   1,  0,   1,  1,  0,   1,   1, 0,   1,  1,  0];

kk = multifit_func (my_cuts(1)-0.35);
kk = kk.set_fun (@mgauss, pars_in);
kk = kk.set_free (pars_free);
[wfit, fitdata] = kk.fit;

acolor black
plot(my_cuts(1)-0.35);
acolor red
pl(wfit);
keep_figure;


% That still wasn't too good. Now start with more realistic values for the
% widths, and bind some of the peak positions to follow symmetry, i.e. the 
% position of peaks for Q<0 are reflection of those at Q>0
pars_in = [0.4,-0.8,0.07, 0.5,-0.22,0.07, 0.5,0.22,0.07, 0.4,0.8,0.07, 0.4,1.2,0.07];
pars_free = [1,   1,   0,   1,    1,   0,   1,   1,   0,   1,  1,   0,   1,  1,   0];
pars_bind = {{2,11,-1}, {5,8,-1}};  % ensures symmetry about x=0
% The syntax above is that each binding is a cell array, which has the form:
%       {ipar_bound, ipar_free, ratio}
% More generally, if there are several functions (see later) then we would
% use the form:
%       {[par_bound,ifun_bound], [ipar_free,ifun_free], ratio}
% However, in this case, there is only one function and it is assumed.
kk = multifit_func (my_cuts(1)-0.35);
kk = kk.set_fun (@mgauss, pars_in);
kk = kk.set_free (pars_free);
kk = kk.set_bind (pars_bind);
[wfit, fitdata] = kk.fit;

acolor black
plot(my_cuts(1)-0.35);
acolor red
pl(wfit);
keep_figure;


% Repeat the above, but using some of the options to restrict the range of fitting
% and produce verbose output
kk = multifit_func (my_cuts(1)-0.35);
kk = kk.set_fun (@mgauss, pars_in);
kk = kk.set_free (pars_free);
kk = kk.set_bind (pars_bind);
kk = kk.set_mask ('keep',[-1,1.5]);
kk = kk.set_options ('list',2);

[wfit, fitdata] = kk.fit;

acolor black
plot(my_cuts(1)-0.35);
acolor red
pl(wfit);
keep_figure;


% Lastly, set a background function as well. In full:
pars_in = [0.4,-0.8,0.07, 0.5,-0.22,0.07, 0.5,0.22,0.07, 0.4,0.8,0.07, 0.4,1.2,0.07];
pars_free = [1,   1,   0,   1,    1,   0,   1,   1,   0,   1,  1,   0,   1,  1,   0];
pars_bind = {{2,11,-1}, {5,8,-1}};  % ensures symmetry about x=0

kk = multifit_func (my_cuts(1));
kk = kk.set_fun (@mgauss, pars_in);
kk = kk.set_free (pars_free);
kk = kk.set_bind (pars_bind);
kk = kk.set_bfun (@linear_bg, [0.35,0]);
kk = kk.set_bfree ([1,0]);
[wfit, fitdata] = kk.fit;

acolor black
plot(my_cuts(1));
acolor red
pl(wfit);
keep_figure;

% Plot the background and sum on one plot
[wfit, fitdata] = kk.fit('components');

acolor black
plot(my_cuts(1));
acolor red
pl(wfit.sum);
pl(wfit.back);
keep_figure;


%% ========================================================================
%                         Make dispersion plots
% =========================================================================

alatt = [2.87, 2.87, 2.87];
angdeg = [90,90,90];

lattice = [alatt, angdeg];
% Reciprocal lattice points to draw dispersion between:
rlp = [0,0,0; 0,0,1; 0,0,0; 1,0,0; 0,0,0; 1,1,0; 0,0,0; 1,1,1];
% Input parameters
pars = [1, 0.05, 0.05, 35, -5, 15, 10, 0.1];
% Energy grid
ecent = [0,0.1,200];
% Energy broadening term
fwhh = 2;
disp2sqw_plot(lattice, rlp, @sr122_disp, pars, ecent, fwhh);


%% ========================================================================
%                   Fit a single cut with an S(Q,w) model
% =========================================================================
% Use the sr122 cross-section here, and fit only a small section, because 
% calculating the cross-section is a lot slower than the dispersion or
% just fitting peaks.
my_new_cut = cut_sqw(sqw_file, proj, [0.5,0.05,1.5], [-1.1,-0.9], [-0.1,0.1], [100,120]);

pars = [1,0,0,35,-5,15,10,0.1];
pfree = [1,0,0,1,1,1,1,1];

kk = multifit_sqw (my_new_cut);
kk = kk.set_fun (@sr122_xsec, pars);
kk = kk.set_free (pfree);
kk = kk.set_bfun (@linear_bg, [0.35,0]);
kk = kk.set_options ('list',2);

[wfit, fitdata] = kk.fit('components');

acolor black
plot(my_new_cut);
acolor red
pl(wfit.sum);
pl(wfit.back);
keep_figure;


% Correct ferromagnetic spin-waves function
% -----------------------------------------
% So far we have used a library function (for SrFe2As2) which
% is not suitable for the dataset we actually have (bcc-Fe). The worksheet
% gave an analytical expression for the cross-section for the expected
% ferromagnetic spin waves and instructed you to modify the library model
% to use the new function which the commands below assumes will be in the
% file Fe_FM_spinwaves.m
%
% In addition, we have also included a "model answer" version which also
% includes the Fe form factor in the file Fe_FM_spinwaves_FF.m

% Simulate our favourite Q-E slice with your cross-section model
test_slice = sqw_eval(my_slice, @Fe_FM_spinwaves_FF, [35 0 30 10 1000]);
plot(test_slice);

% Fit our newly created short cut. There is no separate sensitivity to the
% gap and the exchange constant; oneof them has to be fixed. The temeprature
% also has to be fixed. Also, the background gradient is not well-defined,
% so we fix that too.
pars = [35, 0, 30, 10, 1000];
pfree = [1, 0, 1, 0, 1];

kk = multifit_sqw (my_new_cut);
kk = kk.set_fun (@Fe_FM_spinwaves_FF, pars);
kk = kk.set_free (pfree);
kk = kk.set_bfun (@linear_bg, [0.15,0]);
kk = kk.set_bfree ([1,0]);
kk = kk.set_options ('list',2);

[wfit, fitdata] = kk.fit('components');

acolor black
plot(my_new_cut);
acolor red
pl(wfit.sum);
pl(wfit.back);
keep_figure;


%% ========================================================================
%       Fit multiple cuts simultaneously with a single S(Q,w) model
% =========================================================================
% We will use the array of 1d cuts we made earlier

% ------------------------------------------------
% To begin just use the same input as above, i.e. single parameter set and a
% single set of parameters for the background functions

kk = multifit_sqw (my_cuts);
kk = kk.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);
kk = kk.set_free ([1, 0, 1, 0, 1]);
kk = kk.set_bfun (@linear_bg, [0.1,0]);
kk = kk.set_bfree ([1,0]);
kk = kk.set_options ('list',2);

[wfit, fitdata] = kk.fit('comp');

for i=1:numel(my_cuts)
    acolor black
    plot(my_cuts(i));
    acolor red
    pl(wfit.sum(i));
    pl(wfit.back(i));
    keep_figure;
end

% ------------------------------------------------
% These fits are pretty good, but let's do something a bit more
% sophisticated with the backgrounds: set different background functions
% for different cuts

% Initialise the fitting object
kk = multifit_sqw (my_cuts);
% Our usual starting parameters and bindings for the cross-section:
kk = kk.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);    
kk = kk.set_free ([1, 0, 1, 0, 1]);
% Set background functions, one per dataset
bgfunc = {@linear_bg, @linear_bg, @linear_bg, @quad_bg, @quad_bg};
bgpars = {[0.37,0], [0.2,0], [0.14,0], [0.08,0,0], [0.03,0,0]};
bgfree = {[1,1],    [1,1],   [1,1],    [1,1,1],    [1,1,1]};
kk = kk.set_bfun (bgfunc, bgpars);
kk = kk.set_bfree (bgfree);
% Bind the linear background gradients together. Note how you can accumulate
% bindings a bit at a time
kk = kk.set_bbind({[2,2],[2,1],1},{[2,3],[2,1],1});  % bind gradients for linear bg
kk = kk.add_bbind({[3,5],[3,4],1});

% Ask for copious output
kk = kk.set_options ('list',2);

% Now perform the fit and plot the results
[wfit, fitdata] = kk.fit('comp');

for i=1:numel(my_cuts)
    acolor black
    plot(my_cuts(i));
    acolor red
    pl(wfit.sum(i));
    pl(wfit.back(i));
    keep_figure;
end


% ------------------------------------------------
% Look at a slice with our fit parameters:
test_slice = sqw_eval(my_slice, @Fe_FM_spinwaves_FF, fitdata.p);
plot(my_slice); keep_figure;
plot(test_slice); keep_figure;












