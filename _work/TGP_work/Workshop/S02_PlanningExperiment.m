%% ========================================================================
%                        Planning an experiment
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
%              Use the horace planning tool 
% =========================================================================
% Type the following in Matlab:
%
%   >> horace_planner
%
% and fill in the fields 

%% ========================================================================
%              Make a fake data set to explore more thoroughly 
% =========================================================================

% Name and folder for output "fake" generated file
sqw_file = '../aaa_my_work/my_fake_file.sqw';

% Instrument parameter file (may be in another location to this)
par_file = '../data/4to1_102.par';

% u and v vectors to define the crystal orientation 
% (u||ki, uv plane is horizontal but v does not need to be perp to u.
u = [1, 0, 0]; 
v = [0, 1, 0];

% Range of rotation (psi) angles to cover in simulated dataset.
% (psi=0 when u||ki)
psi = [-75:2.5:75];

% Incident energy in meV
efix = 550;
emode = 1;   % This is for direct geometry (set to 2 for indirect)

% Range of energy transfer (in meV) for the dataset to cover
en = [0:5:500];

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
proj.uoffset = [2, 0, 0];

% Type is Q units for each axis and can be either 'r' for r.l.u. or 'a' 
% for absolute (A^-1). E.g. 'rar' means u and w are normalissed to in r.l.u, v in A^-1.
proj.type = 'rrr';

% Actually, it is better to make a projection object with this information
% rather than a structure. Type: >> doc projaxes   for more details.
% Note that the default for uoffset is [0,0,0,0] so it doesn't need to be set
proj = projaxes([-1,-1,1], [0,1,1], 'uoffset', [2,0,0], 'type', 'rrr');


% Now make a cut of the fake dataset.
% The four vectors indicate either the range and step (three-vector) or
% the integration range (2-vector), with units defined by the proj.type
% The following makes a 2D cut with axes u and energy (first and fourth
% vectors are 3-vectors), integrating over v and w between -0.1 and 0.1
% each. '-nopix' will be discussed in session 5
my_cut = cut_sqw(sqw_file, proj, [-1,0.05,1], [-0.1,0.1], [-0.1,0.1], [0,10,400], '-nopix');

% Now plot the 2D cut.
plot(my_cut);

% We can also make a 3D volume cut:
my_vol = cut_sqw(sqw_file, proj, [-4,0.05,4], [-4,0.05,4], [-0.1,0.1], [0,10,400], '-nopix');

% And plot it, so we can move through and see 2D projections of the volume
plot(my_vol);
