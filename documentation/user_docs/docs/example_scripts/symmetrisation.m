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
%                            Symmetrisation
% =========================================================================
sqw_file = [output_data_folder '/iron.sqw'];
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
