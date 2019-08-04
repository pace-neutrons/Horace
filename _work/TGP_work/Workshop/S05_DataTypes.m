%% ========================================================================
%                        Different kinds of data
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
%                             sqw data
% =========================================================================
% Name of sqw file (for the 4D combined dataset)
sqw_file = '../aaa_my_work/iron.sqw';


% Get information about an sqw or dnd file on hard drive
head_horace(sqw_file)
head_sqw(sqw_file)
head_dnd(sqw_file)


% SQW objects are created from cut_sqw by default. We now recreate the
% 3D slice we made in session 3, and then interrogate its properties
my_vol = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], [-0.1,0.1], [0,4,360]);

% Display a summary of an sqw object
head(my_vol)

% Get the number of contributing pixels
% Note that the pix array is a 9xN array where N is the number of pixels
% The 9 different fields are described if you type: help get_data_form
size(my_vol.data.pix)

% Get the size of the signal array
size(my_vol.data.s)

% Get the size of the axes (note that they are they are bin boundaries
% - that is, they should be one bigger than the size of the signal array
% above.
size(my_vol.data.p{1})

% Notice number of pix is same as number of pix!!
sum(sum(sum(my_vol.data.npix)))

% For more detailed investigation, convert into a structure array:
gg = get(my_vol)

% Information about how file was created (use newer fuller file for this!)
nfiles = numel(gg.header)

% Gets the orientation directions u and v (where u||ki when psi=0).
cu = gg.header{1}.cu
cv = gg.header{1}.cv

% To shows how much memory sqw objects take up, compare with the corresponding
% dnd object:
my_d3d = d3d(my_vol);
whos my_vol my_d3d
% See how the d3d object is much smaller in memory than the original sqw


%% ========================================================================
%                             dnd data
% =========================================================================

% Repeat the above (with data field) for my_d3d, to confirm that it is the
% same, but that much metadata has been thrown away.

head(my_d3d)

% size(my_d3d.pix) % DND objects have no pix array, so this will fail.

size(my_d3d.s)
size(my_d3d.p{1})
sum(sum(sum(my_d3d.npix)))
gg = get(my_d3d)

% The following commands will fail because the metadata including which
% datafile each pixel comes from, and the original orientation matrix has
% been lost.
nfiles = numel(gg.header);
cu = gg.header{1}.cu;
cv = gg.header{1}.cv;


%% ========================================================================
%                        Binary and unary operations
% =========================================================================

% Create a two-dimensional sqw object:
w1 = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280]);

% Unary operations:
w1_exp = exp(w1); 

w1_d2d = d2d(w1);
w1_d2d_exp = exp(w1_d2d);

plot(w1_d2d_exp)
keep_figure;

% Binary operations:

% Add a number:
plot(w1 + 5);
plot(w1_d2d + 5);

% Add two objects:
w2 = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], [-0.1,0.1], [100,120]);
w3 = cut_sqw(sqw_file, proj, [-3,0.05,3], [-3,0.05,3], [-0.1,0.1], [120,140]);

w2_d2d = d2d(w2);
w3_d2d = d2d(w3);

plot(w2_d2d + w3_d2d);

plot(w2 + w3); % this does not work because of different size of pix arrays!

%% ========================================================================
%                  Output data to file in various formats
% =========================================================================

% Save to sqw file:
save(w2,[data_path,'my_w2.sqw']);

% Read it back in again
w2a=read_sqw([data_path,'my_w2.sqw']);

% Save dnd:
save(w2_d2d,[data_path,'my_w2.d2d']);

% Read it back in again
w2b=read_dnd([data_path,'my_w2.d2d']);

% Save data to ascii file, for use in some other program:
save_xye(w2_d2d,[data_path,'my_w2_ascii.dat']);

% Split an sqw object into an array of sqw objects, each one made from just
% one of the contributing spe datasets
w1_array = split(w1);

% Examine sqw data with run_inspector:
run_inspector(w1, 'ax', [-3,3,0,270], 'col', [0,3]);


%% ========================================================================
%              Decompose a full sqw object into NXSPE files
% =========================================================================
% We'll do this for a very small sqw file. Note that this capability should
% only be used on full sqw files i.e. ones that were made using gen_sqw or
% accumulate_sqw. While saved output from using cut_sqw produces sqw files as
% well, these will in general only contain parts of the contributing NXSPE
% files. Consequently the NXSPE files cannot be reconstructed.

% Create a small sqw file from just two datasets. This is the same code as
% in the example where we generated an sqw file, but where only two spe
% files are used, not the full set of 46 files.
data_path = '../data/';
sqw_file = '../aaa_my_work/iron_tiny.sqw';
par_file = '';
u = [1, 0, 0]; 
v = [0, 1, 0];
psi = [0:2];
runno = [15052:15093];
efix = 401;
emode = 1;   % This is for direct geometry (set to 2 for indirect)
alatt = [2.87, 2.87, 2.87];
angdeg = [90, 90, 90];
omega=0; dpsi=0; gl=0; gs=0;
efix_for_name = 400;
for i=1:numel(psi)
    spefile{i} = [data_path, 'map', num2str(runno(i)), '_ei', num2str(efix_for_name), '.nxspe'];
end
gen_sqw (spefile, par_file, sqw_file, efix, emode, alatt, angdeg,...
    u, v, psi, omega, dpsi, gl, gs);

% Load sqw file in memory
w4 = read_sqw(sqw_file);

% Divide full sqw object into array of objects corresponding to each run
warr = split(w4);

% Get rundatah file, corresponding to the run
rh = rundatah(warr(2));
rh.saveNXSPE('my_recoverted_nxspe');
