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
%                            Parallelisation
% =========================================================================

% Horace can carry out some operations in parallel using MPI.
% If you are using the Data Analysis as a Service (DAaaS) platform, then
% everything should be setup.
% You can query the current parallel setup using
hpc;
% This should print a summary of the current settings
% If the summary says that `build_sqw_in_parallel` is 0 (zero) then the
% parallisation is turned off. You can turn it on with:
hpc on

% You can further tweak the settings by creating a configuration instance:
hpcconf = hpc_config()
% Now you can set the properties of this `hpcconf` object to set the 
% parallel configuration.
% E.g. to change the number of parallel workers to 6:
hpcconf.parallel_workers_number = 6
% Or to change the method for combining tmp files into an sqw file
hpcconf.combine_sqw_using = 'mex_code'
% (the options for this are: 'matlab', 'mex_code', 'mpi_code')
% Or to change the parallelisation method:
hpcconf.parallel_cluster = 'parpool'
% (the options are: 'herbert', 'parpool', 'mpiexec_mpi', 'slurm_mpi')
% To use the 'parpool' option you must have the Parallel Toolbox installed.


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
%                            Symmetrisation
% =========================================================================
proj = projaxes([1,1,0], [-1,1,0], 'type', 'rrr');

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

