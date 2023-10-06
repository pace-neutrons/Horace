%% Before running this script, set the data path here

global edatc_folder output_data_folder

% To run this script you need some files from the EDATC
% Please download a zip of the repository here:
% https://github.com/pace-neutrons/edatc/archive/refs/heads/main.zip
% And put the location you unzipped it below:
edatc_folder = '/mnt/ceph/auxiliary/pace/edatc';
% Note that you should also download the Zenodo archive here:
% https://zenodo.org/record/5020485
% And unzip the contents of that file into the crystal_datafiles folder

% Put the folder where you want generated files from this script to go:
output_data_folder = '/tmp/aaa_my_work';

% Creates output folder if it doesn't exist
if ~exist(output_data_folder, 'dir')
    mkdir(output_data_folder)
end

%% ========================================================================
%                         Simulation and Fitting
% =========================================================================

clear variables
global edatc_folder output_data_folder
if ~exist('sr122_xsec', 'file')
    addpath([edatc_folder '/matlab_scripts']);
end

%% ========================================================================
%                Simulating a pre-prepared S(Q,w) function
% =========================================================================

% Create cuts and slices for use later
sqw_file = [output_data_folder '/iron.sqw'];
proj = line_proj([1,1,0], [-1,1,0]);

% Make our usual 2d slice
my_slice = cut(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);

% Make the array of 1d cuts previous made in the advance plotting session
energy_range = [80:20:160];
for i = 1:numel(energy_range)
    my_cuts(i) = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], ...
        [-10 10]+energy_range(i));
end

% Simulate on sqw objects
parameter_vector = [1, 0, 0, 35, -5, 15, 10, 0.1];

sim_slice = sqw_eval(my_slice, @sr122_xsec, parameter_vector);
sim_cut = sqw_eval(my_cuts, @sr122_xsec, parameter_vector);

% Repeat on dnd objects
sim_slice_dnd = sqw_eval(d2d(my_slice), @sr122_xsec, parameter_vector);
sim_cut_dnd = sqw_eval(d1d(my_cuts), @sr122_xsec, parameter_vector);

plot(sim_slice);
keep_figure;

plot(sim_slice_dnd);
keep_figure;

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
fwhh = 5;
disp2sqw_plot(lattice, rlp, @sr122_disp, pars, ecent, fwhh);
