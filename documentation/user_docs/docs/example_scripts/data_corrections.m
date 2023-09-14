%% Before running this script, set the data path here

global edatc_folder output_data_folder

% To run this script you need some files from the EDATC
% Please download a zip of the repository here:
% https://github.com/pace-neutrons/edatc/archive/refs/heads/main.zip
% And put the location you unzipped it below:
edatc_folder = '/mnt/nomachine/pace/edatc';
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
%                            Rescaling data
% =========================================================================

sqw_file = [output_data_folder '/iron.sqw'];
proj = projaxes([1,1,0], [-1,1,0], 'type', 'rrr');

% Bose correction function.
% NB it does not do much at high energies, or course!

my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);
plot(my_slice);
lz 0 2
keep_figure;

my_slice_bose = bose(my_slice, 300); % pretend the data was taken at 300K...
plot(my_slice_bose); % you can still see what this does
lz 0 2


%% ========================================================================
%                            Miscellaneous
% =========================================================================

% Note the following doesn't work on IDAaaS at the moment as the signal() function was wrongly removed!)
%{
% If you want to see how a certain parameter varies across a dataset:
w_sig = signal(my_slice, 'Q'); % mod Q in this case
plot(w_sig)

% You can use this now to apply a scale factor to the data. Suppose you wish
% to multiply signal by energy:
w_sig = signal(my_slice, 'E');
my_slice2 = my_slice * w_sig;
plot(my_slice2)
lz 0 100
%}

% Take a section out of a dataset:
w_sec = section(my_slice, [0, 2.5], [100, 250]); % just 0 to 2.5 in Q, 100 to 250 in energy
plot(w_sec);


% Split a dataset up into its contributing runs
w_split = split(my_slice);
% w_split is an array of objects (recall indexing of arrays in Matlab)
% each element of the array corresponds to the data from a single
% contributing spe file
plot(w_split(1)); keep_figure;
plot(w_split(10)); % etc.
% Allows you to determine if a spurious or strange signal is coming from a
% single run, or if it is from a collection of runs.

