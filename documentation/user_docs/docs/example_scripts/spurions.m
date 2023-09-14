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
%                            Spurious data
% =========================================================================
w_sp1 = sqw([edatc_folder '/crystal_datafiles/spurious1.sqw']);
par_file = [edatc_folder '/crystal_datafiles/4to1_102.par'];

cut1_sp1 = cut(w_sp1, [], [-0.1 0.1], []);
plot(cut1_sp1)
% You should see an intense streak at the Bragg position.
% Lets look at a reciprocal space map of it
plot(cut(w_sp1, [], [], [-2 2])); lz(0, 2000); keep_figure;
plot(cut(w_sp1, [], [], [8 12])); lz(0, 2000); keep_figure;
% You should see that there are 3 streaks all in the same direction,
% all coming out of a Bragg peak.
run_inspector(cut1_sp1)
% Move through the runs – you should see around run 22 that there is a very
% intense diagonal streak which is present in several runs.

% The excitations are too intense and are not symmetric about the Bragg peak
% so they are not real dispersion, but because they are associated with the
% sample Bragg peak, it suggests they _are_ scattering from the sample.
% In fact they are a detector artefact. This happens because the crystal
% is aligned such that equivalent off-plane Bragg peaks hit a single detector
% tube at the same time causing the electronics to misrecord neutron events,
% because the peaks are so intense.

%% The second dataset
w_sp2 = read_sqw([edatc_folder '/crystal_datafiles/spurious2.sqw'])
plot(w_sp2)
% You should see that there are Bragg peaks but they don’t seem to have the
% 6-fold symmetry you would expect from the (111) plane of a cubic crystal.
run_inspector(w_sp2, 'col', [0,10000])
% Move through the run_inspector. You should see that the sqw file was formed
% of a set of 46 scans from 0 to 90 deg in 2 deg steps, and then another
% 45 scans from 1 to 89 deg in 2 deg steps.
% Comparing runs 22-27 and 69-74 (you can use run_inspector twice to get 2 plots)
% you should see the scattering is similar but doesn't match up
% (e.g. run 22 looks like run 70 but are 5 degrees apart).
% This is because during the rotation from 90 deg to 1 deg for the second set
% of scans, the sample assembly became stuck and the motor lost its position
% So the second set was not actually measuring from 1 to 89 deg.

%% ========================================================================
%                            Masking data
% =========================================================================
% Mask parts of a dataset out, e.g. if there is a region with a spurion that
% you wish to remove before proceeding to fitting the data
sqw_file = [output_data_folder '/iron.sqw'];
proj = projaxes([1,1,0], [-1,1,0], 'type', 'rrr');
my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);
mask_arr = ones(size(my_slice.data.npix)); % keeps everything
mask_arr2 = mask_arr;
mask_arr2(61:121,:) = 0;

my_slice_masked1 = mask(my_slice,mask_arr); % should do nothing
my_slice_masked2 = mask(my_slice,mask_arr2);

plot(my_slice_masked1); keep_figure;
plot(my_slice_masked2); keep_figure;

% Mask out specific points, if the mask you need for the above is more
% complex:
sel1 = mask_points(my_slice,   'keep', [-1,1,100,120]); % specify limits to keep

sel2 = mask_points(my_slice, 'remove', [-1,1,100,120]); % specify limits to remove

my_slice_masked3 = mask(my_slice, sel1);
my_slice_masked4 = mask(my_slice, sel2);

plot(my_slice_masked3); keep_figure;
plot(my_slice_masked4); keep_figure;

%% Masking spurious data
cut_sp1 = cut(w_sp1, [-0.6 -0.5], [], [])
plot(cut_sp1); keep_figure
% Determine the mask – best way is to plot the actual picture with pcolor
%figure; pcolor(w_sp1.data.s); caxis([0,1000])
% Then determine the coordinates from this (remember that pcolor transposes the matrix)
mask_arr_sp = ones(size(cut_sp1.data.npix));
mask_arr_sp(40:42, 57:59) = 0;
wmasked = mask(cut_sp1, mask_arr_sp)
plot(wmasked);
