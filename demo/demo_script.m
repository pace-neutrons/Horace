%This is a Matlab script file to demonstrate some of the basic features of
%Horace. For a description of what each function is doing, and pictures of
%what the various plots should look like, visit
%http://horace.isis.rl.ac.uk/Getting_started

%In order to run this demo you may need to change some of the directory and
%file names in order to match up to your own operating system and file
%structure. It has been assumed that Horace has been installed and your
%initialised in your startup.m so that it is ready to run

%==================================================================================================
% Give folder where you want to want to install the demo
% *** This folder MUST already exist
%==================================================================================================
%demo_dir='c:\temp\horace_demo';
%demo_dir=pwd;
demo_dir=fileparts(which('demo_script'));

%==================================================================================================
% Unzip the data contained in the demo folder, and copy demo
%==================================================================================================
demo_root_dir = [fileparts(which('horace_init')),filesep,'demo',filesep];
demo_dir = fullfile(demo_dir,filesep);   % add file separator if not there
%unzip([demo_root_dir 'Horace_demo.zip'],demo_dir);
try
copyfile(fullfile(demo_root_dir,'demo_par.PAR'),fullfile(demo_dir,'demo_par.PAR'))
copyfile(fullfile(demo_root_dir,'demo_par.PHX'),fullfile(demo_dir,'demo_par.PAR'))
copyfile(fullfile(demo_root_dir,'demo_4gauss_2dQ.m'),fullfile(demo_dir,'demo_4gauss_2dQ.m'))
copyfile(fullfile(demo_root_dir,'demo_FM_spinwaves_2dSlice_sqw.m'),...
    fullfile(demo_dir,'demo_FM_spinwaves_2dSlice_sqw.m'))
catch
end
%==================================================================================================
% Script to create sqw file
%==================================================================================================
% Give locations of input files
indir=demo_dir;     % source directory of spe files
par_file=[indir 'demo_par.PAR'];     % detector parameter file
sqw_file=[indir 'fe_demo.sqw'];        % output sqw file
data_source =sqw_file;

% Set incident energy, lattice parameters etc.
efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

% Create the list of file names and orientation angles
nfiles=24;
psi=linspace(0,-1*(nfiles-1),nfiles);
spe_file=cell(1,nfiles);
for i=1:length(psi)
    spe_file{i}=[indir,'MAP',num2str(11012+(2*i)),'.SPE'];
end

% Create sqw file
gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
         u, v, psi, omega, dpsi, gl, gs);

% ---------------------------------------     
% If the intermediate files (extensions .tmp) are all created, but the sqw
% file is not created (will sometimes happen if you have many spe files):

% tmp_file=cell(1,nfiles);    % create list of tmp file names
% for i=1:length(psi)
%     tmp_file{i}=[indir,'MAP',num2str(11012+(2*i)),'.tmp'];
% end
% write_nsqw_to_sqw(tmp_file,sqw_file);
% ---------------------------------------     



%==================================================================================================
%==================================================================================================
% Now plot, manipulate and fit data
%==================================================================================================
%==================================================================================================


%==================================================================================================
% Plot some of our data:
%==================================================================================================
% Set up a structure which defines the axes for cutting
proj_100.u = [1,0,0];
proj_100.v = [0,1,0];
proj_100.type = 'rrr';
proj_100.uoffset = [0,0,0,0];

% 1D cut:
w100_1 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,[-0.2,0.2],[60,70]);
plot(w100_1)

% 2D cut
w100_2 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,[-0.2,0.2],[0,0,500]);
plot(w100_2)

% 3D sliceomatic figure:
w100_3 = cut_sqw(data_source,proj_100,[-0.2,0.2],0.05,0.05,[0,0,500]);
%plot(w100_3)


%==================================================================================================
% Data manipulation:
%==================================================================================================

% 2D cut: without keeping hte individual pixel information
w110_2a = cut_sqw(data_source,proj_100,[-0.2,0.2],[1,0.05,3],[-0.2,0.2],[0,0,150],'-nopix');

% Make a 1D background cut
wbackcut = cut(w110_2a,[2.8,3],[]);

% Construct a 2D background that we can subtract from the 2D cut:
wback = replicate(wbackcut,w110_2a);  %NB the replicate method has not yet been implemented for SQW
plot(wback);

% Subtract from the 2D cut
wdiff = w110_2a - wback;
plot(wdiff);
lz 0 1



%==================================================================================================
% Test some simulation and fitting functions:
%==================================================================================================

% Simulations:
% ============

% Make a template 2D cut
w_template=cut_sqw(data_source,proj_100,[-0.4,0.2],[0,0.05,3],[-0.5,0.05,3],[30,40]);
plot(w_template)
lz 0 4
keep_figure;

% Simulate the 4 peaks:
% (This is an example of simulating using a function of the plot axes.
% Generally the user would write a simulate function themself to pass to func_eval)
w_sim=func_eval(w_template,@demo_4gauss_2dQ,[6 1 1 0.1 2 1 1]);
plot(w_sim)
lz 0 4
keep_figure

% Simulate a model for S(Q,w):
% (This is an example where the user can provide the spectral weight as a
% function of (vector) Q and energy)
w_sqw=sqw_eval(w_template,@demo_FM_spinwaves_2dSlice_sqw,[300 0 2 10 2]);
plot(w_sqw)
keep_figure


%==========================================================================
% Try doing some fitting now:

% Fit the function of the plotting axes:
[w_fit1,fitdata1]=fit(w_template,@demo_4gauss_2dQ,[6 1 1 0.1 2 1 1],[1 1 1 1 0 0 1],'list',2);
plot(w_fit1)
lz 0 4
keep_figure

% Fit the function of S(Q,w):
% First create an appropriate fake dataset from the simulation done above: add some noise:
w_fixup = d2d(w_sqw);
w_fixup.s = w_fixup.s + rand(size(w_fixup.s)).*w_fixup.s; % add some noise to the simulation
w_fixup.e = rand(size(w_fixup.s)).*w_fixup.s;             % make dummy errorbars
plot(w_fixup)

% Now fit this fake data:
[w_fit2,fitdata2]=fit_sqw(w_fixup,@demo_FM_spinwaves_2dSlice_sqw,[200 0 2 10 2],[1 1 1 0 1],'list',1);
plot(w_fit2)
keep_figure
