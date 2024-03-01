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
%                    Correcting for sample misalignment
% =========================================================================
clear variables
global edatc_folder output_data_folder

% ========================================================================
% Name of output sqw file (for the 4D combined dataset)
sqw_file = [output_data_folder '/iron.sqw'];

% Make a series of hk-slices at different l, in order to work out what Bragg
% positions we have. Step sizes and energy integration should be customised for your data
% Step sizes should be as small as possible, and energy integration tight.

proj = line_proj([1,0,0], [0,1,0]);

alignment_slice1=cut(sqw_file, proj, [-5, 0.03, 8], [-5, 0.03, 8], [-0.05, 0.05], [-10, 10], '-nopix');
plot(compact(alignment_slice1));
keep_figure;

alignment_slice2=cut(sqw_file, proj, [0.95, 1.05], [-5, 0.03, 8], [-3, 0.03, 3], [-10, 10], '-nopix');
plot(compact(alignment_slice2));
keep_figure;

alignment_slice3=cut(sqw_file, proj, [-5, 0.03, 8], [-0.05, 0.05], [-3, 0.03, 3], [-10, 10], '-nopix');
plot(compact(alignment_slice3));
keep_figure;

% Look at the 3 orthogonal slices to figure out what bragg peaks are visible


% Our notional Bragg peaks - a list of accessible Bragg peaks (in data they
% may be off from these notional positions)
bragg_peaks=[4,0,0; 2,0,0; 1,1,0; 4,4,0; 1,0,1];

% Get the actual Bragg peak positions with the current crystal alignment
% This routine takes radial and transverse cuts around the Bragg peaks listed
% above. See the help for further information about how the routine works -
% you will in general have to adjust some of the inputs here, especially the
% energy window
[rlu0, width, wcut, wpeak]=bragg_positions(sqw_file, bragg_peaks, 1.5, 0.06, 0.4, ...
                                     1.5, 0.06, 0.4, 20, 'gauss', 'bin_ab');

% Check how well the function did (note the command line prompts to allow you
% to scan through the cuts made above)
bragg_positions_view(wcut, wpeak)

% Determine corrections to lattice and orientation (in this example we choose
% to keep the lattice angles fixed, but allow the lattice parameters to be
% refined, keeping a cubic structure by keeping ratios of lattice pars to be same):
alatt = [2.87, 2.87, 2.87];   % original lattice parameters
angdeg = [90, 90, 90];
[rlu_corr, alatt, angdeg, ~, ~, rotangle] = refine_crystal(rlu0, alatt, angdeg, ...
    bragg_peaks, 'fix_angdeg', 'fix_alatt_ratio');


% Apply changes to sqw file. For the purposes of this examples sheet you might
% want to copy the file in case you have made a mistake. In practice, you shouldn't
% make a copy as the sqw file could many hundreds of gigabytes and could take
% along time to copy.
sqw_file_new = [output_data_folder '/iron_aligned.sqw'];
copyfile(sqw_file, sqw_file_new)
change_crystal(sqw_file_new, rlu_corr);

% Check the outcome: Get Bragg peak positions and look at output: should be much better
[rlu0, width, wcut, wpeak]=bragg_positions(sqw_file_new, bragg_peaks, 1.5, 0.06, 0.4, ...
                                     1.5, 0.06, 0.4, 20, 'gauss', 'bin_ab');
bragg_positions_view(wcut, wpeak)

%=========
% Generally you only want to figure out the misorientation once, then apply
% some correction to subsequent data. You can do this by finding the values
% of the notional goniometers gl, gs, dpsi that are used in gen_sqw:

u = [1, 0, 0];
v = [0, 1, 0];
alatt = [2.87, 2.87, 2.87];   % original lattice parameters
angdeg = [90, 90, 90];
omega=0; dpsi=0; gl=0; gs=0;

[alatt, angdeg, dpsi, gl, gs] = crystal_pars_correct...
    (u, v, alatt, angdeg, omega, dpsi, gl, gs, rlu_corr);
% u and v are the notional scattering plane, alatt0, angdeg0, etc are the
% original values for those parameters you used in gen_sqw, rlu_corr is the
% misalignment correction matrix determined above. The routine outputs the
% corrected lattic parameters (if these were refined) and the values of
% dpsi, gl and gs to use in future regenerations of the sqw file.
