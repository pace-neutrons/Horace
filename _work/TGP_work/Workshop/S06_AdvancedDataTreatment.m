%% ========================================================================
%                          Advanced data treatment
% =========================================================================

% NOTE - For help about the syntax of any command, type in Matlab:
% >> help routine_name
%  or
% >> doc routine_name
%
% EXAMPLES
% To prints in the Matlab command window the help for the gen_sqw routine
% >> help gen_sqw
%
% To displays the help for gen_sqw in the Matlab documentation window
% >> doc gen_sqw

clear variables


%% ========================================================================
%  Background subtraction (including cuts, replication, binary operation)
% =========================================================================

% Recreate the Q-E slice from earlier
sqw_file = '../aaa_my_work/iron.sqw';
proj.u  = [1,1,0]; proj.v  = [-1,1,0]; proj.uoffset  = [0,0,0,0]; proj.type  = 'rrr';

my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);
plot(my_slice)
lz 0 2

my_bg = cut(my_slice, [1.9,2.1], []);
plot(my_bg);

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

% If you want to see how a certain parameter varies across a dataset:
w_sig = signal(my_slice, 'Q'); % mod Q in this case
plot(w_sig)

% You can use this now to apply a scale factor to the data. Suppose you wish
% to multiply signal by energy:
w_sig = signal(my_slice, 'E');
my_slice2 = my_slice * w_sig;
plot(my_slice2)
lz 0 100

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

% Mask parts of a dataset out, e.g. if there is a region with a spurion that
% you wish to remove before proceeding to fitting the data
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

