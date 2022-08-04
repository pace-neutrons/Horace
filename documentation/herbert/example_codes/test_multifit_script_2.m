%% ===================================================================================
% Simultaneous fit of several two-dimensional datasets with constrained
% parameters accross data sets

nw = 5;
win = repmat(IX_dataset_2d, nw, 1);
for i=1:nw
    x1 = linspace_rand(50,70,21,0.2);
    x2 = linspace_rand(1040,1060,21,0.2);
    win(i) = IX_dataset_2d (x1,x2);
end

height = 100; centre = [60, 1050]; covmat = [10, 5, 20];
pf = [height, centre, covmat(:)'];     % parameters as needed by gauss2d

const = 10; df_by_dx1 = 0; df_by_dx2 = 0;
pb = [const, df_by_dx1, df_by_dx2];    % parameters for planar background

% Create dataset with 2d Gaussian on planar background as data
for i=1:nw
    pf(1) = pf(1) + 0.1*pf(1);          % successively increase Gaussian height
    win(i) = func_eval(win(i), @gauss2d, pf);         % 'foreground' model
    pb(1) = pb(1) + 0.1*pb(1);          % successively increase background
    win(i) = win(i) + func_eval(win(i), @linear2D_bg, pb);   % add 'background' model
    win(i) = noisify (win(i), 'poisson');           % noisify with poisson noise
end


% Multifit with slow function evaluation. The result of a fit should
% be parameters that are the same as the ones for which the simulation
% was created
nslow = 0;    % each function evaluation of the 2D Gaussian will take
                % the same time as ~25000 exponentiations
kk = multifit (win);
pf0 = [100, 65, 1055, 12, 3, 25];   % starting parameters different from initial parameters
kk = kk.set_local_foreground;       % independent functions for each dataset
kk = kk.set_fun (@slow_func, {pf0, @gauss2d, nslow});     % set all functions with same initial parameters
kk = kk.set_bind ({2,[2,1],1}, {3,[3,1],1});    % bind centres to all be the same
kk = kk.add_bind ({6,[6,1],1});     % bind variance of x2 to be the same in all datasets
pb0 = [15,0,0];
kk = kk.set_bfun (@slow_func, {pb0, @linear2D_bg, nslow});
kk = kk.set_bfree ([1,0,0]);

% Perform fit
kk = kk.set_options ('listing', 2);  % print results at each iteration
[wfit, ffit] = kk.fit;

% Plot fit
% da(wfit)
