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
