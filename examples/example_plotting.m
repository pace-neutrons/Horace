%% =============================================================================
%   Initialise for running plot examples
% ==============================================================================

% Load data
[w1_point, w1_hist, w2_point, w2_hist, w3_point, w3_hist, ...
    w2oneD_point_xy, w2oneD_point_x_hist_y, w3_unequal,...
    sqw1d, sqw2d, sqw3d, sqw4d, im1d, im2d, im3d, im4d] = data_for_plots;

% Delete all Matlab figures
clearfigs       % genie graphics function


%% =============================================================================
%   IX_dataset_1d plotting
% ==============================================================================

% Create a 'Horace 1D plot' genie_figure: (will be given 'Current' status)
dl (w1_point(1))	% 'draw line'

% Create a fresh figure: (clears the axes in the current 'Horace 1D plot' genie_window)
dh (w1_point(2))	% 'draw histogram'

% Overplot on the current 'Horace 1D plot'
pl (w1_point(1))	% 'plot line'

% Keep the current genie_figure: (gives it `Keep` status)
keep_figure	% alternatively, use the `Keep` menu item on the genie_figure)

% Request another plot
dl (w1_point(1))	% 'draw line' (creates a second 'Horace 1D plot' genie_figure)
keep_figure         % keep this figure too

% Change color sequence for plotting array of IX_dataset_1d
acolor('r','b')     % red followed by blue
dh(w1_hist)         % array of two datasets


%% =============================================================================
%   IX_dataset_2d plotting
% ==============================================================================

% Area plot. Will be in a new window as this is an area plot, not a 1D line plot
da(w2_hist)     % array of two datasets

% Change limits
lx -5 40
ly 105 125

% Draw surface plot. Will be in a new window as surface plots are considered a
% different type of plot
ds(w2_hist)     % array of two datasets

% Now draw surface plot where the colour scale is given by the error bars
% This could be useful if, for example, the 'signal' is the dispersion relation
% in 2D, and the 'error' is the spectral weight. (That was exactly the reason I
% implemented this function)
ds2(w2_hist)



