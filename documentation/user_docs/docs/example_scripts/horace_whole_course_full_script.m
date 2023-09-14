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

%% ==================
edatc_folder = '/home/mdl27/src/edatc';
output_data_folder = '/tmp/aaa_my_work';

% Creates output folder if it doesn't exist
if ~exist(output_data_folder, 'dir')
    mkdir(output_data_folder)
end

%% ========================================================================
%              Make a fake data set to explore more thoroughly 
% =========================================================================

% Name and folder for output "fake" generated file
sqw_file = [output_data_folder '/my_fake_file.sqw'];

% Instrument parameter file (may be in another location to this)
par_file = [edatc_folder '/crystal_datafiles/4to1_102.par'];

% u and v vectors to define the crystal orientation 
% (u||ki, uv plane is horizontal but v does not need to be perp to u.
u = [1, 0, 0]; 
v = [0, 1, 0];

% Range of rotation (psi) angles to cover in simulated dataset.
% (psi=0 when u||ki)
psi = [0:5:90];

% Incident energy in meV
efix = 401;
emode = 1;   % This is for direct geometry (set to 2 for indirect)

% Range of energy transfer (in meV) for the dataset to cover
en = [0:4:360];

% Sample lattice parameters (in Angstrom) and angles (in degrees)
alatt = [2.87, 2.87, 2.87];
angdeg = [90, 90, 90];

% Sample misalignment angles ("gonios"). [More details in session 4].
omega=0; dpsi=0; gl=0; gs=0;

% This runs the command to generate the "fake" dataset.
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
                     u, v, psi, omega, dpsi, gl, gs);

%% ========================================================================
% Once generated, you can use standard Horace plotting tools to explore 
% this fake dataset, where the colour scale corresponds to the value of psi
% that contributed data to a given region of reciprocal space					 

% First define a view projection (these u and v do not need to be the same
% as the sample u and v above. They just define the first, second and third
% axes for making a cut (third axis w is implicit being perpendicular to the 
% plane defined by u and v).
proj.u = [-1, -1, 1]; 
proj.v = [0, 1, 1]; 

% The 4th offset coordinate is energy transfer 
proj.uoffset = [0, 0, 0, 0];

% Type is Q units for each axis and can be either 'r' for r.l.u. or 'a' 
% for absolute (A^-1). E.g. 'rar' means u and w are normalissed to in r.l.u, v in A^-1.
proj.type = 'rrr';

% Actually, it is better to make a projection object with this information
% rather than a structure. Type: >> doc projaxes   for more details.
% Note that the default for uoffset is [0,0,0,0] so it doesn't need to be set
proj = projaxes([-1,-1,1], [0,1,1], 'uoffset', [0,0,0,0], 'type', 'rrr');

% Now make a cut of the fake dataset.
% The four vectors indicate either the range and step (three-vector) or
% the integration range (2-vector), with units defined by the proj.type
% The following makes a 3D volume cut with axes u, v and energy 
% (first, second and fourth vectors are 3-vectors), 
% integrating over w between -0.1 and 0.1.
% '-nopix' indicates to discard the pixel information and create
% a dnd (d3d) object.
my_vol = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], ...
                 [-0.1,0.1], [0,4,360], '-nopix');

% Plot the 3D cut - click on the graph to plot 2D projections of the volume
plot(my_vol)

% The following makes a 2D cut with axes u and energy (first and fourth
% vectors are 3-vectors), integrating over v and w between -0.1 and 0.1
my_cut = cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1], [0,10,400], '-nopix');

% Now plot the 2D cut.
plot(my_cut);

% We set the offset to be centred on (200), (020) and (002) in turn
% Plotting the dispersion along the [h00] direction (note different u and v)
% Using keep_figure to keep the figures on screen.
% Afterwards, you can check which figure gives the largest coverage.
proj = projaxes([1,0,0], [0,1,0], 'uoffset', [2,0,0,0], 'type', 'rrr');
plot(cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1], [0,4,360], '-nopix'));
keep_figure;

proj = projaxes([1,0,0], [0,1,0], 'uoffset', [0,2,0,0], 'type', 'rrr');
plot(cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1], [0,4,360], '-nopix'));
keep_figure;

proj = projaxes([1,0,0], [0,1,0], 'uoffset', [0,0,2,0], 'type', 'rrr');
plot(cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1], [0,4,360], '-nopix'));
keep_figure;

% As an alternative, we could manually change the integration range in the relevant
% axes instead, but using uoffset is easier:
% proj = projaxes([1,0,0], [0,1,0], 'type', 'rrr');
% w200 = cut_sqw(sqw_file, proj, [-1,0.05,1]+2, [-0.1,0.1], [-0.1,0.1], [0,4,360], '-nopix')
% w020 = cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1]+2, [-0.1,0.1], [0,4,360], '-nopix')
% w002 = cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1]+2, [0,4,360], '-nopix')

% Use a different projection to make a 2D slice along [hhh] centred at (200)
proj = projaxes([1,1,1], [0,1,0], 'uoffset', [2,0,0,0], 'type', 'rrr');
plot(cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1], [0,4,360], '-nopix'));

%% ========================================================================
%                        Generating an sqw file 
% =========================================================================
clear variables
close all

global edatc_folder output_data_folder

% Directory where data (spe or nxspe) files are:
data_path = [edatc_folder '/crystal_datafiles']; 

% Name of output sqw file (for the 4D combined dataset)
sqw_file = [output_data_folder '/iron.sqw'];

% Instrument parameter file name (only needed for spe files - nxspe files
% have the par file embedded in them).
%par_file = [data_path, '4to1_102.par'];
par_file = '';

% u and v vectors to define the crystal orientation 
% (u||ki when psi=0; uv plane is horizontal but v does not need to be perp to u).
u = [1, 0, 0]; 
v = [0, 1, 0];

% Range of rotation (psi) angles of the data files.
% (psi=0 when u||ki)
psi = [0:2:90];

% Data file run number corresponding to the psi angles declared above
% (must be the same size and order as psi)
runno = [15052:15097];

% Incident energy in meV
efix = 401;
emode = 1;   % This is for direct geometry (set to 2 for indirect)

% Sample lattice parameters (in Angstrom) and angles (in degrees)
alatt = [2.87, 2.87, 2.87];
angdeg = [90, 90, 90];

% Sample misalignment angles ("gonios"). [More details in session 4].
omega=0; dpsi=0; gl=0; gs=0;

% Construct the data file names from the run numbers (the data file names
% are actually what is required by the gen_sqw function below, but we
% use the numbers as a convenience. This assumes that the data file names
% follow the standard convention of IIInnnnnn_eiEEE.nxspe, where III is
% the instrument abbreviation (MAP, MER or LET), nnnnnn is the run number
% and EEE is the incident energy.
spefile = cellfun(@(c) fullfile(data_path, ['map' num2str(c) '_ei400.nxspe']), ...
                                num2cell(runno), 'UniformOutput', false);
% A loop also works:
%for i=1:numel(psi)
%    spefile{i} = [data_path, 'map', num2str(runno(i)), '_ei400', '.nxspe'];
%end

% Now run the function to generate the sqw file.
gen_sqw (spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
    u, v, psi, omega, dpsi, gl, gs);

%% ========================================================================
%                Accumulating data to an existing sqw file
% =========================================================================
%
% The above gen_sqw file generates an sqw file from the list of input
% spe or nxspe files in one go, and deletes all temporary files after it
% finishes. If you are in the middle of a rotation scan, you can use
% accumulate_sqw which does not delete the temporary files and so can
% append newly processed spe/nxspe files to an existing sqw file.
% This may save some time in processing, but is not now generally
% recommended since the implementation of parallelisation in gen_sqw has
% made gen_sqw much faster.
%
% This is because accumulate_sqw needs to know _all_ the psi values
% (including those not yet measured) in order to construct  coarse data
% grid that enables Horace to make fast cuts. If you then include
% measurements at psi values not in the original list, then it is possible
% that some data will lie outside this grid and it will be 'lost' to the
% sqw file. If the additional runs are ones that interleave between the
% original files, this will not be a problem, but if the additional runs
% extend the original angular range, then you must use the 'clean' option
% which is equivalent to gen_sqw.
%
% The syntax for accumulate_sqw is very similar to gen_sqw:
%
% accumulate_sqw(spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                u, v, psi, omega, dpsi, gl, gs)
%
% Or:
% accumulate_sqw(spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                u, v, psi, omega, dpsi, gl, gs, 'clean')
%
% This is a way of appending newly processed spe files to an existing
% dataset. The key point is that the psi and spe_file arrays contain a list
% of PLANNED files and run-numbers - only those that actually exist will be
% included in the file.
%
% You can run this periodically, for example overnight.


%% ========================================================================
%                         Making cuts and slices
% =========================================================================

% Before making a cut, we have to define viewing (projection) axes, and
% these u and v do not need to be the same as the sample orientation which
% is defined by u and v above (where u||ki at psi=0).
% These u and v just define the Q axes for cut_sqw. Generally you only need
% to define the first two axes, u and v. The third axis w is implicitly
% constructed as being perpendicular to the plane defined by u and v.
% The units of the Q axes are specified by the 'type', which can be 'r'
% for r.l.u. or 'a' for absolute units (A^-1).
% E.g. 'rar' means u and w are in r.l.u, v in A^-1.
% The offset gives a offset for the zero of that axis, with the fourth
% coordinate being the energy transfer in meV.
proj.u  = [1,1,0];
proj.v  = [-1,1,0];
proj.uoffset  = [0,0,0,0];
proj.type  = 'rrr';

% Alternatively, you can make a projection object with this information
% rather than a structure. Type: >> doc projaxes   for more details.
% Note that the default for uoffset is [0,0,0,0] so it doesn't need to be set
proj = projaxes([-1,-1,1], [0,1,1], 'uoffset', [0,0,0,0], 'type', 'rrr');

% The syntax for cut_sqw is:
%
% cut = cut_sqw(sqw_file, proj, u_axis_limits, v_axis_limits, w_axis_limits, ...
%               en_axis_limits, keywords)
%
% The *_axis_limits are either:
%   1. a single number, [0.05], which means that this axis will be plotted
%      with the number being the bin size and limits being the limits of
%      the data.
%   2. two numbers, [-1, 1], which means that this axis will be integrated
%      over between the specified limits.
%   3. three numbers, [-1, 0.05, 1], which means that this axis will be
%      plotted between the first value to the last value with the bin size
%      specified by the middle value.

% In the following we make 3d volume plots along u, v and energy and
% integrating over the w direction. The '-nopix' at the end means that
% cut_sqw will discard all pixel information - that is it will only retain
% the counts and errors for each bin rather than keep the counts of each
% neutron event which is enclosed by each bin. This saves a lot of memory
% and is good enough for plotting but would not be good enough for fitting,
% or for re-cutting as shown below.
my_vol = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], [-0.1,0.1], [0,4,360], '-nopix');
plot(my_vol);

% Now we make 2D slices integrating over both v and w in Q.
my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);
plot(my_slice);

% Now we make a 1D cut along u, timing how long it takes.
tic
my_cut = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [130,150]);
toc
plot(my_cut);

% In addition to cutting from an sqw file, you can also cut from a previous
% cut. Note that if the previous cut had used '-nopix', the cut bins must
% be aligned with the old cut. Thus if you want to re-cut a cut, do not
% use '-nopix'.
tic
my_cut2 = cut(my_slice, [], [130,150]);
% The [] above is to keep 1st axes as it is, [130,150] is integration range
% for 2nd axis note because the object we are cutting from is 2d, we only
% need 2 binning arguments, rather than the 4 that are needed when taking a
% cut form the 4-dimensional dataset in the file
toc

plot(my_cut2);
% This plot is identical to my_cut, but was much faster to create.
% Imagine if you were running a script to take many cuts from the data - it
% is probably quicker to take them from existing data objects, where
% possible!

% For use with later example scripts, save a cut and slice
save(my_slice, [output_data_folder '/iron_slice.sqw'])
save(my_cut, [output_data_folder '/iron_cut.sqw'])

%% ========================================================================
%                     Basic customisation of plots
% =========================================================================

% Make axes tight:
plot(compact(my_slice));

% Smoothing:
%plot(smooth(my_slice)); % this gives an error - think about why!

%
plot(smooth(d2d(my_slice)));
% d2d command (for 2d objects) converts from sqw type data, with detector pixel retained
% to d2d / dnd object that is smaller in memory and without detector pixel info

% Smoothing options:
plot(smooth(d2d(my_slice),[2,2],'gaussian'));

% Set colour scale and other axes scales in script:
lz 0 0.5
ly 50 250
lx -1.5 1.5

% Reset a limit
lx

% Retain a figure, so it is not replaced next time you make a plot (of the
% same dimensionality)
keep_figure;
plot(my_slice);

% Cursor to find a particular data point value
plot(my_cut2);
xycursor

%% ========================================================================
%                Plotting data with non-orthogonal axes
% =========================================================================

% To demonstrate plotting a non-orthogonal axes system we will use data
% from a crystal with hexagonal symmetry

sqw_nonorth = [data_path, '/upd3_elastic.sqw'];
proj_nonorth.u = [1, 0, 0];
proj_nonorth.v = [0, 1, 0];
proj_nonorth.type = 'rrr';
proj_nonorth.nonorthogonal = false; % <--- Default sets to false

% If proj.nonorthogonal is false, u, v and w will be reconstructed to be
% orthogonal. The plots will have correct aspect ratio but it will be
% harder to tell the right reciprocal lattice coordinates by eye.
ws_orth = cut_sqw(sqw_nonorth, proj_nonorth, [-7,0.02,3], [-2,0.02,2], [-0.1,0.1], [-1,1]);
plot(ws_orth)
keep_figure()

% Now set the projection axes to non-orthogonal
proj_nonorth.nonorthogonal = true;
ws_nonorth = cut_sqw(sqw_nonorth, proj_nonorth, [-7,0.02,3], [-2,0.02,2], [-0.1,0.1], [-1,1]);
plot(ws_nonorth); keep_figure();

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

proj.u = [1,0,0];
proj.v = [0,1,0];
proj.uoffset = [0,0,0];
proj.type = 'rrr';

alignment_slice1=cut_sqw(sqw_file,proj,[-5,0.03,8],[-5,0.03,8],[-0.05,0.05],[-10,10],'-nopix');
alignment_slice2=cut_sqw(sqw_file,proj,[0.95,1.05],[-5,0.03,8],[-3,0.03,3],[-10,10],'-nopix');
alignment_slice3=cut_sqw(sqw_file,proj,[-5,0.03,8],[-0.05,0.05],[-3,0.03,3],[-10,10],'-nopix');

% Look at the 3 orthogonal slices to figure out what bragg peaks are visible
plot(compact(alignment_slice1)); keep_figure;
plot(compact(alignment_slice2)); keep_figure;
plot(compact(alignment_slice3)); keep_figure;

% Our notional Bragg peaks - a list of accessible Bragg peaks (in data they
% may be off from these notional positions)
bragg_peaks=[4,0,0; 2,0,0; 1,1,0; 4,4,0; 1,0,1];

% Get the actual Bragg peak positions with the current crystal alignment
% This routine takes radial and transverse cuts around the Bragg peaks listed
% above. See the help for further information about how the routine works -
% you will in general have to adjust some of the inputs here, especially the
% energy window
[rlu0,width,wcut,wpeak]=bragg_positions(sqw_file, bragg_peaks, 1.5, 0.06, 0.4,...
                                     1.5, 0.06, 0.4, 20, 'gauss','bin_ab');

% Check how well the function did (note the command line prompts to allow you
% to scan through the cuts made above)
bragg_positions_view(wcut,wpeak)

% Determine corrections to lattice and orientation (in this example we choose
% to keep the lattice angles fixed, but allow the lattice parameters to be
% refined, keeping a cubic structure by keeping ratios of lattice pars to be same):
alatt = [2.87,2.87,2.87];   % original lattice parameters
angdeg = [90,90,90];
[rlu_corr,alatt,angdeg,~,~,rotangle] = refine_crystal(rlu0, alatt, angdeg,...
    bragg_peaks,'fix_angdeg','fix_alatt_ratio');


% Apply changes to sqw file. For the purposes of this examples sheet you might
% want to copy the file in case you have made a mistake. In practice, you shouldn't
% make a copy as the sqw file could many hundreds of gigabytes and could take
% along time to copy.
sqw_file_new = [output_data_folder '/iron_aligned.sqw'];
copyfile(sqw_file,sqw_file_new)
change_crystal_horace(sqw_file_new, rlu_corr);

% Check the outcome: Get Bragg peak positions and look at output: should be much better
[rlu0,width,wcut,wpeak]=bragg_positions(sqw_file_new, bragg_peaks, 1.5, 0.06, 0.4,...
                                     1.5, 0.06, 0.4, 20, 'gauss','bin_ab');
bragg_positions_view(wcut,wpeak)

%=========
% Generally you only want to figure out the misorientation once, then apply
% some correction to subsequent data. You can do this by finding the values
% of the notional goniometers gl, gs, dpsi that are used in gen_sqw:

u = [1,0,0];
v = [0,1,0];
alatt = [2.87,2.87,2.87];   % original lattice parameters
angdeg = [90,90,90];
omega=0; dpsi=0; gl=0; gs=0;

[alatt, angdeg, dpsi, gl, gs] = crystal_pars_correct...
    (u, v, alatt, angdeg, omega, dpsi, gl, gs, rlu_corr);
% u and v are the notional scattering plane, alatt0, angdeg0, etc are the
% original values for those parameters you used in gen_sqw, rlu_corr is the
% misalignment correction matrix determined above. The routine outputs the
% corrected lattic parameters (if these were refined) and the values of
% dpsi, gl and gs to use in future regenerations of the sqw file.

%% ========================================================================
%             Advanced plotting and publication quality figures
% =========================================================================
clear variables
global edatc_folder output_data_folder

% ========================================================================
%                          Two dimensional plot
% =========================================================================
sqw_file = [output_data_folder '/iron.sqw'];

rlp = [1,-1,0; 2,0,0; 1,1,0; 1,-1,0];
wspag = spaghetti_plot(rlp,sqw_file,'qbin',0.1,'qwidth',0.3,'ebin',[0,4,250]);
lz 0 3



%% ========================================================================
%                          Two dimensional plot
% =========================================================================

% Recreate the Q-E slice from earlier, this time without saving the pixel
% information
proj.u  = [1,1,0]; proj.v  = [-1,1,0]; proj.uoffset  = [0,0,0,0]; proj.type  = 'rrr';

my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280], '-nopix');

% Plot the 2d slice first:
plot(smooth(compact(my_slice)));

% Set limits
lx -2 2
ly 40 250
lz 0 0.5

% Make a nicer title
title('My QE slice');

% Label the axes with something nicer
xlabel('(1+h,-1+h,0) (r.l.u.)');
ylabel('Energy (meV)');

% Get rid of the colour slider
colorslider('delete');
colorbar

% If we want to set the font sizes to be bigger, then we have to re-do the
% above:
title('My QE slice', 'FontSize', 16);
xlabel('(1+h,-1+h,0) (r.l.u.)', 'FontSize', 16);
ylabel('Energy (meV)', 'FontSize', 16);

% To set the font size of the ticks, we need to access the figure's axes.
my_handles = get(gca)
% there are many things you can adjust! To set the font size, or any of the
% other properties, do the following:
set(gca, 'FontSize', 16);

% Suppose we want to change what tick marks are used on the x-axis
set(gca, 'XTick', -2:0.5:2);
set(gca, 'XTickLabel', arrayfun(@num2str, -2:0.5:2, 'UniformOutput', false));

%Put some text on the figure:
text(-0.5, 220, 'Ei = 400 meV', 'FontSize', 16);

% Some fancier text to label the colour bar:
tt = text(3.2, 240, 'Intensity (mb sr^{-1} meV^{-1} f.u.^{-1})', 'FontSize', 16);
set(tt, 'Rotation', -90)

%Save as jpg and eps
print('-djpeg', [output_data_folder '/figure.jpg']);
print('-depsc', [output_data_folder '/figure.eps']);


%% ========================================================================
%                          One dimensional plots
% =========================================================================

% Make an array of 1d cuts:
energy_range = [80:20:160];
for i = 1:numel(energy_range)
    my_cuts(i) = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], ...
        [-10 10]+energy_range(i));
end

% plot them individually, to see what they look like first
for i = 1:numel(energy_range)
    plot(my_cuts(i)); keep_figure;
end

% We want to plot them all on the same axes, with different colours and
% markers.
my_col={'black','red','blue','green','yellow'};
my_mark={'+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
% note the above are all the possible choices!

for i = 1:numel(my_cuts)
    acolor(my_col{i})
    amark(my_mark{i});
    if i==1
        plot(my_cuts(i));
    else
        % The pp command overplots (markers and errorbars) on existing 1d axes
        pp(my_cuts(i));
    end
end

% This is a bit messy. Let's add a constant offset between each cut, and make
% the markers bigger
my_offset=[0:0.3:1.2];
for i = 1:numel(my_cuts)
    acolor(my_col{i})
    amark(my_mark{i},6);
    if i==1
        plot(my_cuts(i) + my_offset(i));
    else
        pp(my_cuts(i) + my_offset(i));
    end
end

% But we could have done this much more cleanly using the vectorised capabilities
% of Horace functions
acolor({'black','red','blue','green','yellow'})
amark({'+', 'o', '*', '.', 'x', 's'},6)
my_cut_offset = my_cuts + [0:0.3:1.2];
dp(my_cut_offset)


% Now need to extend axes to see everything:
lx -2 2
ly 0 1.8

% Use the same settings as before to get nice font sizes
title('Q cuts', 'FontSize', 16);
xlabel('(1+h,-1+h,0) (r.l.u.)', 'FontSize', 16);
ylabel('Intensity (mb sr^{-1} meV ^{-1} f.u.^{-1})', 'FontSize', 16);
set(gca, 'FontSize', 16);
set(gca, 'XTick', -2:0.5:2);
set(gca, 'XTickLabel', arrayfun(@num2str, -2:0.5:2, 'UniformOutput', false));

% Insert a figure legend
legend('80 meV','100 meV','120 meV', '140 meV','160 meV');

% But this is wrong!!! This is a peculiarity of Horace, in that it plots the
% markers then the errorbars, and Matlab doesn't keep track of this. Luckily
% there is a workaround, by getting a "handle" to each plot and then
% attaching the legend to that.

for i = 1:numel(my_cuts)
    acolor(my_col{i})
    amark(my_mark{i},8);
    if i==1
        [fig_handle, axes_handle, plot_handle] = plot(my_cuts(i) + my_offset(i));
    else
        [fig_handle, axes_handle, plot_handle] = pp(my_cuts(i) + my_offset(i));
    end
end
lx -2 2
ly 0 1.8

%legend(plot_handle([10,8,6,4,2]), ...
%       {'80 meV','100 meV','120 meV', '140 meV','160 meV'}, ...
%       'Location','NorthWest');

% You can also manually edit the plot, using the arrow tool to highlight
% part of the plot you want to change. e.g. you can remove the box around
% the legend by setting its colour to be white

% Reset the plot color to black
acolor k

%% ========================================================================
%                         Background Subtraction
% =========================================================================
% Recreate the Q-E slice from earlier
sqw_file = [output_data_folder '/iron.sqw'];
proj = projaxes([1,1,0], [-1,1,0], 'type', 'rrr');
my_slice = cut_sqw(sqw_file, proj, ...
                   [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,360]);
plot(my_slice)
keep_figure;
lz(0,2)

% Make a 1D cut from the slice at high Q
my_bg = cut(my_slice, [1.9,2.1], []);
plot(my_bg);

% Now tile it (note the conversion to dnd)
my_bg_rep = replicate(d1d(my_bg), d2d(my_slice));
plot(my_bg_rep)
lz 0 2

my_slice_subtracted = d2d(my_slice) - my_bg_rep;
plot(my_slice_subtracted);
lz 0 2

%% ========================================================================
%                            Symmetrisation
% =========================================================================
my_slice2 = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], [-0.1,0.1], [100,120]);
plot(my_slice2);

% Fold along vertical:
my_sym = symmetrise_sqw(my_slice2, [-1,1,0], [0,0,1], [0,0,0]);
plot(my_sym);

% Two folds along diagonals
my_sym2 = symmetrise_sqw(my_slice2, [1,0,0], [0,0,1], [0,0,0]);
my_sym2 = symmetrise_sqw(my_sym2, [0,1,0], [0,0,1], [0,0,0]);
plot(my_sym2);

% Some origami!
my_slice3 = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], [-2,0.05,2], [100,120]);
plot(my_slice3)

sym1 = symmetrise_sqw(my_slice3, [0,1,0], [1,0,0], [0,0,0]);
plot(sym1);

sym2 = symmetrise_sqw(sym1, [1,0,0], [0,0,1], [0,0,0]);
sym2 = symmetrise_sqw(sym2, [0,1,0], [0,0,1], [0,0,0]);
plot(sym2)

% Squeeze out all the dead volume
plot(compact(sym2))

% You can also perform whole-dataset symmetrisation with gen_sqw()
% when the sqw file is created. (Whole dataset symmetrisation is not
% supported after the sqw if create at the moment).
% First you need to define a symmetrisation function such as:
%
%function wout = my_sym(win)
%    % Fold above the line [1,0,0] in the H-K plane
%    wout = symmetrise_sqw(win, [1,0,0], [0,1,0], [0,0,0]);
%end
%
% In a separate mfile. Then you can call gen_sqw with the "transform_sqw"
% argument, e.g.:
%
%gen_sqw(spefile, par_file, sym_sqw_file, efix, emode, alatt, angdeg,...
%        u, v, psi, omega, dpsi, gl, gs,'transform_sqw', @my_sym)

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
run_inspector(w_sp2, 'col', [0,1000])
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

%% ========================================================================
%                            Rescaling data
% =========================================================================

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


