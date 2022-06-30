%% ===================================================================================
%
% Example test script to show how to create multi-dimensional Gaussians
% for testing parallel multifit.
%
%  The examples are for 1D, 2D and 3D. The demonstrate the use of the
% functions slow_func1d, slow_func2d and slow_func3d to massively increase
% the function evaluation time of the Gaussian (or any other function of
% the particular dimensionality) in order to increase the CPU load.
%
% Use these to construct test fits for a selection of different arrays of
% different sizes to benchmark parallel multifit.
%
%% ===================================================================================
% One-dimensional example
x1 = 1:100;

w = IX_dataset_1d (x1);

height = 1000; centre = 60; stdev = 10;
pf = [height, centre, stdev];       % parameters as needed by gauss

const = 10; df_by_dx1 = 0;
pb = [const, df_by_dx1];            % parameters for linear background

% Create dataset with 1d Gaussian on planar background as data
w = func_eval(w, @gauss, pf);           % 'foreground' model
w = w + func_eval(w, @linear_bg, pb);   % add 'background' model
win = noisify (w, 'poisson');           % noisify with poisson noise

acolor('k') % black lines
dp(win)     % plot data

% Multifit with slow function evaluation. The result of a fit should
% be parameters that are the same as the ones for which the simulation
% was created
nslow = 10000;  % each function evaluation of the 2D Gaussian will take
                % the same time as ~250,000 exponentiations
kk = multifit (win);
pf0 = [1100, 66, 13];   % starting parameters different from initial parameters
kk = kk.set_fun (@slow_func1d, {pf0, @gauss, nslow});
pb0 = [15,0]; 
kk = kk.set_bfun (@slow_func1d, {pb0, @linear_bg, nslow});
kk = kk.set_bfree ([1,0]);

% Perform fit
kk = kk.set_options ('listing', 1);  % print results at each iteration
[wfit, ffit] = kk.fit;

% Plot fit on top of the initial data
acolor('r') % red lines
pl(wfit)    % overplot fit



%% ===================================================================================
% Two-dimensional example
x1 = 50:70;
x2 = 1040:1060;

w = IX_dataset_2d (x1,x2);

height = 1000; centre = [60, 1050]; covmat = [10, 5, 20];
pf = [height, centre, covmat(:)'];     % parameters as needed by gauss2d

const = 10; df_by_dx1 = 0; df_by_dx2 = 0;
pb = [const, df_by_dx1, df_by_dx2];    % parameters for planar background

% Create dataset with 2d Gaussian on planar background as data
w = func_eval(w, @gauss2d, pf);         % 'foreground' model
w = w + func_eval(w, @linear2D_bg, pb);   % add 'background' model
win = noisify (w, 'poisson');           % noisify with poisson noise

% To plot:
% da(win)   % plot data
% keep_figure     % keep the figure


% Multifit with slow function evaluation. The result of a fit should
% be parameters that are the same as the ones for which the simulation
% was created
nslow = 1000;    % each function evaluation of the 2D Gaussian will take
                % the same time as ~25000 exponentiations
kk = multifit (win);
pf0 = [1100, 66, 1055, 12, 3, 25];   % starting parameters different from initial parameters
kk = kk.set_fun (@slow_func2d, {pf0, @gauss2d, nslow});
pb0 = [15,0,0]; 
kk = kk.set_bfun (@slow_func2d, {pb0, @linear2D_bg, nslow});
kk = kk.set_bfree ([1,0,0]);

% Perform fit
kk = kk.set_options ('listing', 1);  % print results at each iteration
[wfit, ffit] = kk.fit;

% Plot fit
% da(wfit)




%% ===================================================================================
% Three-dimensional example
x1 = 50:70;
x2 = 1040:1060;
x3 = 100:130;

w = IX_dataset_3d (x1,x2,x3);

height = 1000; centre = [60, 1050, 116]; covmat = [10, 5, 7, 20, -6, 15];
pf = [height, centre, covmat(:)'];     % parameters as needed by gauss2d

const = 10; df_by_dx1 = 0; df_by_dx2 = 0; df_by_dx3 = 0;
pb = [const, df_by_dx1, df_by_dx2, df_by_dx3];    % parameters for planar background

% Create dataset with 2d Gaussian on planar background as data
w = func_eval(w, @gauss3d, pf);         % 'foreground' model
w = w + func_eval(w, @linear3D_bg, pb);   % add 'background' model
win = noisify (w, 'poisson');           % noisify with poisson noise

% You can view the 3D data interactively with:
%   plot(win)

% Multifit with slow function evaluation. The result of a fit should
% be parameters that are the same as the ones for which the simulation
% was created
nslow = 100;    % each function evaluation of the 2D Gaussian will take
                % the same time as ~2500 exponentiations
kk = multifit (win);
pf0 = [1100, 66, 1055, 117, 15, 3, 5, 30, -3, 20];   % starting parameters different from initial parameters
kk = kk.set_fun (@slow_func3d, {pf0, @gauss3d, nslow});
pb0 = [15,0,0,0]; 
kk = kk.set_bfun (@slow_func3d, {pb0, @linear3D_bg, nslow});
kk = kk.set_bfree ([1,0,0,0]);

% Perform fit
kk = kk.set_options ('listing', 1);  % print results at each iteration
[wfit, ffit] = kk.fit;

