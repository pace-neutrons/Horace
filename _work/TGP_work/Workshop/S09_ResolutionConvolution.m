%% ========================================================================
%                         Resolution Convolution
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
%                  Fitting with resolution convolution
% =========================================================================
% We will use the same array of 1d cuts but now account for resolution

%-----------------------------------
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


%-----------------------------------
% The first thing we need to do is attach instrument and sample size 
% information to the cuts. We can do this to the sqw file itself, and the
% information will be propagated to any cut that outputs an sqw object. 
% We can attach it to the cuts themselves, and that is what we will do here.

% Create a sample - something not totally dissimilar to the Fe crystal shape
sample = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.03,0.03,0.04]);

% Create an instrument description
ei = 401;
freq = 600;
chopper = 'S';
instru = maps_instrument(401, freq, chopper);

% We can now set the sample and instrument
my_cuts_tf = set_sample (my_cuts, sample);

my_cuts_tf = set_instrument (my_cuts_tf, instru);


%-----------------------------------
% Now fit one of the cuts
% ------------------------
% Initialise the fitting object
tf = tobyfit (my_cuts_tf(1));
tf = tf.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);    
tf = tf.set_free ([1, 0, 1, 0, 1]);
tf = tf.set_bfun (@linear_bg, [0.37,0]);
tf = tf.set_bfree ([1,0]);
tf = tf.set_options ('list',2);

% Now perform the fit and plot the results
[wfit_tf, fitdata_tf] = tf.fit('comp');

acolor black
plot(my_cuts_tf(1));
acolor red
pl(wfit_tf.sum);
pl(wfit_tf.back);
keep_figure;

% Compare with no including resolution convolution
kk = multifit_sqw (my_cuts_tf(1));
kk = kk.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);    
kk = kk.set_free ([1, 0, 1, 0, 1]);
kk = kk.set_bfun (@linear_bg, [0.37,0]);
kk = kk.set_bfree ([1,0]);
kk = kk.set_options ('list',2);

% Now perform the fit and plot the results
[wfit, fitdata] = kk.fit('comp');

acolor black
plot(my_cuts_tf(1));
acolor red
pl(wfit.sum);
pl(wfit.back);
keep_figure;


%-----------------------------------
% Now fit all five cuts simultaneously
% ------------------------------------
% Initialise the fitting object
tf = tobyfit (my_cuts_tf);
tf = tf.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);    
tf = tf.set_free ([1, 0, 1, 0, 1]);
tf = tf.set_bfun (@linear_bg, [0.37,0]);
tf = tf.set_bfree ([1,0]);
tf = tf.set_options ('list',2);

% Now perform the fit and plot the results
[wfit_tf, fitdata_tf] = tf.fit('comp');

for i=1:numel(my_cuts_tf)
    acolor black
    plot(my_cuts_tf(i));
    acolor red
    pl(wfit_tf.sum(i));
    pl(wfit_tf.back(i));
    keep_figure;
end


% Compare with no including resolution convolution
kk = multifit_sqw (my_cuts_tf);
kk = kk.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);    
kk = kk.set_free ([1, 0, 1, 0, 1]);
kk = kk.set_bfun (@linear_bg, [0.37,0]);
kk = kk.set_bfree ([1,0]);
kk = kk.set_options ('list',2);

% Now perform the fit and plot the results
[wfit, fitdata] = kk.fit('comp');

for i=1:numel(my_cuts_tf)
    acolor black
    plot(my_cuts_tf(i));
    acolor red
    pl(wfit.sum(i));
    pl(wfit.back(i));
    keep_figure;
end


%-----------------------------------
% Now fit one of the cuts, change the contributions
% ------------------------
% Now we will change the number of Monte Carlo points per and fit turning
% off the moderator pulse width

% Initialise the fitting object
tf = tobyfit (my_cuts_tf(2));
tf = tf.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);    
tf = tf.set_free ([1, 0, 1, 0, 1]);
tf = tf.set_bfun (@linear_bg, [0.37,0]);
tf = tf.set_bfree ([1,0]);
tf = tf.set_options ('list',2);

% Now change number of Monte Carlo points to 15
tf = tf.set_mc_points(15);

% Fit
[wfit_ref, fitdata_ref] = tf.fit('comp');

% Fit with no chopper contribution
tf = tf.set_mc_contributions('nochop');
[wfit_nochop, fitdata_nochop] = tf.fit('comp');


%-----------------------------------
% Semi-global foreground
% Now fit all five cuts simultaneously
% ------------------------------------
% We will allow the intensities and lifetime to vary for each of the cuts, 
% but constrain the exchnage constant to be the same for all cuts
% Initialise the fitting object
tf = tobyfit (my_cuts_tf);

tf = tf.set_local_foreground;
tf = tf.set_fun (@Fe_FM_spinwaves_FF, [35, 0, 30, 10, 300]);   
tf = tf.set_free ([1, 0, 1, 0, 1]);
tf = tf.set_bind ({1,[1,1],1});     % check you understand this syntax

tf = tf.set_bfun (@linear_bg, [0.37,0]);
tf = tf.set_bfree ([1,0]);
tf = tf.set_options ('list',2);

% Now perform the fit and plot the results
[wfit_tf, fitdata_tf] = tf.fit('comp');

for i=1:numel(my_cuts_tf)
    acolor black
    plot(my_cuts_tf(i));
    acolor red
    pl(wfit_tf.sum(i));
    pl(wfit_tf.back(i));
    keep_figure;
end











