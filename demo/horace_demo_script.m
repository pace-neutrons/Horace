%demo script, guiding you through the process of using the basic features
%of Horace from the Matlab command line


% Define working directories, used by this script
%First of all ensure that the current directory of Matlab is the directory
%in which this script file is located (otherwise the following line will
%not work).
demo_dir = fileparts(mfilename('fullpath'));
indir=demo_dir; % source directory of spe (or nxspe) files
%               % We will generate demo source files  in this directory,
%               % but usually this  folder is the folder with data 
%               % reduction results
par_file=fullfile(indir,'4to1_124.par'); % detector parameters (positions) file.
%                                       % Old spe files need this but modern 
%                                       % reduction script puts this data into
%                                       % each nxspe file, so par-file may 
%                                       % be lef empty. If it is not emptpy, it
%                                       % contents will override the contents
%                                       % stored in nxspe files.
sqw_file=fullfile(indir,'fe_demo.sqw'); % let's place output sqw file into
%                                       % init directory.
% after generation, sqw file becomes the source of further analysis.
% When script completed successfully, file will be deleted.
data_source =sqw_file;


%====================================
%% Generate Horace data files
%====================================
%Run the command below to obtain the data we will use for the demo. This
%process can take a few minutes - be patient! Provide sqw file name as
%additional parameter, to ensure that if sqw is already there, you do not 
%need to generated source files again. Generation of sqw file will not be
%demonstrated as the result. Will demonstrate only operations with sqw.
file_list=setup_demo_data(sqw_file);

%At the end of this you should have a set of files called
%HoraceDemoDataFileN.spe, where N is 1 to 23.

%We will now generate the SQW file that lies at the heart of Horace. It
%combines the data from several runs (23 in this case) into one single data
%source, data from which can then be cut and sliced along any direction in
%4-dimensional reciprocal space:

% Set incident energy, lattice parameters etc.
efix=787;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

% Create the list of file names and orientation angles
psi=0:4:90;%the angle of the sample w.r.t. the incident beam for each run.
%psi=0 is defined when u is parallel to the incident beam (in this case
%u=[1,0,0] - see above).

nfiles=numel(psi);
if exist('file_list','var')
    spe_file = file_list;
else
    spe_file=cell(1,nfiles);
    for i=1:length(psi)
        spe_file{i}=fullfile(indir,['HoraceDemoDataFile',num2str(i),'.nxspe']);
        if ~exist(spe_file{i},'file')
            spe_file{i}=fullfile(indir,['HoraceDemoDataFile',num2str(i),'.spe']);
        end
    end
end
if ~isfile(sqw_file)
    gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
        u, v, psi, omega, dpsi, gl, gs);
end

%============================================
%% Analyze dava visually. Make cuts and plots
%============================================

%Viewing axes to look at the data. These can be any orthogonal set you like
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

%3D slice - view using sliceomatic
cc3=cut_sqw(sqw_file,proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],[0,16,700],'-nopix');
save(cc3,'cut3D_sqw.sqw');
plot(cc3);
%notice the '-nopix' option - we chose not to retain in memory the
%information about every contributing detector pixel for this slice. Using
%-nopix means we use less memory, but also lose some information about the
%underlying data.

%2D slice
cc2=cut_sqw(sqw_file,proj,[-2,0.05,1],[-2.1,-1.9],[-0.1,0.1],[100,16,400]);
plot(cc2);

%1D cut
cc1=cut_sqw(sqw_file,proj,[1.9,2.1],[-3,0.05,3],[-0.1,0.1],[180,220]);
plot(cc1);

% Cuts along hkl-directions
hklline = [0 0 0; 0.5 0.5 0.5; 0.5 0.5 0; 0 0.5 0; 0 0 0];
bzpts = {'\Gamma','R','M','X','\Gamma'};
bzcen = [2 2 0];
wsp=spaghetti_plot(hklline+repmat([2 2 0],size(hklline,1),1),sqw_file,'labels',bzpts, ...
    'ebin',[10,10,500],'qbin',0.1,'qwidth',1,'smooth',0,'clim',[0.5 2]);

%================================
%% Data manipulation
%================================

%Take a cut that we can use later as a background references:
backgroundcut=cut(cc2,[-0.05,0.05],[]);%keep the binning the same in 2nd axis, but integrate over
%a given range in the first to produce a 1d cut

%"replicate" this 1d cut so that it covers the full range of the 2d slice
%we took it from. But because we still have pixel info, and what we are
%doing "breaks" the relationship between the raw data and what we are
%plotting on the screen, we have to throw the pixel info away. We do this
%by converting from an sqw object to a d2d / d1d object:
backgroundcut=d1d(backgroundcut);
dd2=d2d(cc2);
wback = replicate(backgroundcut,dd2);  %NB the replicate method has not yet been implemented for SQW
plot(wback);

% Subtract from the 2D cut
wdiff = dd2 - wback;
plot(wdiff);

%==================================
%% Simulation and fitting
%==================================

cc2a=cut_sqw(sqw_file,proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],[180,220]);
plot(cc2a)
keep_figure;

% Simulate a model for S(Q,w):
% (This is an example where the user can provide the spectral weight as a
% function of (vector) Q and energy)
w_sqw=sqw_eval(cc2a,@demo_FM_spinwaves,[250 0 2.4 10 5]);
%Looks vaguely like the data.

% Simulation parameters are 300 0 2 10 2 and we try to recover it
%Do a fit. We'll fit parameters 1, 3 and 5 in our model, but leave 2 and 4
%fixed (2nd vector is list of free parameters). We will
%also have a backgound function (specified separately). The (optional) list
%argument gives a verbose output during the fitting process
J = 250;     % Exchange interaction in meV
D = 0;       % Single-ion anisotropy in meV
gam  = 2.5;   % Intrinsic linewidth in meV (inversely proportional to excitation lifetime)
temp = 10; % Sample measurement temperature in Kelvin
amp  = 1;  % Magnitude of the intensity of the excitation (arbitrary units)

kk = multifit_sqw (cc2a);
kk = kk.set_fun (@demo_FM_spinwaves);

kk = kk.set_pin ([J D gam temp amp]); %input parameters
kk = kk.set_free ([1 0 1 0 1]); %fitting parameters 1, 3 and 5

kk = kk.set_bfun (@constant_background); % set_bfun sets the background functions
kk = kk.set_bpin (0.05);   % initial background constant
kk = kk.set_bfree (1);    % fix the background
kk = kk.set_options('fit_control_parameters',[0.001 30 0.001],'listing',2);
sh = kk.simulate();
[wfit_hor fitdata_hor]=kk.fit();
plot(wfit_hor)
keep_figure
try
    %Use spinW to calculate the S(Q,w) instead. First setup the spinW model.

    %spinW v3 naming convention.
    fefm = spinw;
    
    fefm.genlattice('lat_const',[2.87 2.87 2.87],'angled',[90 90 90],'sym','I m -3 m');
    fefm.addatom('r',[0 0 0],'S',2.5,'label', 'MFe3');
    fefm.gencoupling();
    fefm.addmatrix('label','J','value',-1);
    fefm.addcoupling('mat','J','bond',1);

    fefm.addmatrix('value',diag([0 0 -1]),'label','D');
    fefm.addaniso('D');
    fefm.genmagstr('mode','direct','S',[0,0; 0,0;1,1]);

    cpars = {'mat', {'J', 'D(3,3)'}, 'hermit', false, 'optmem', 1, 'useFast', true, 'resfun', 'sho', 'formfact', false};

    kk = multifit_sqw (cc2a);
    kk = kk.set_fun (@fefm.horace_sqw, {[50 0 2 10 0.1], cpars{:}});

    %kk = kk.set_pin ({[250 0 2.4 10 5],fefm}); %input parameters
    kk = kk.set_free ([1 0 1 0 1]); %fitting parameters 1,3 and 5

    kk = kk.set_bfun (@constant_background); % set_bfun sets the background functions
    kk = kk.set_bpin (0.05);   % initial background constant
    kk = kk.set_bfree (1);    % fix the background
    kk = kk.set_options('fit_control_parameters',[0.001 30 0.001],'listing',2);    
    ssw = kk.simulate();
    [wfit_sw fitdata_sw]=kk.fit();

catch ME
    warning(ME.identifier,'Problem with spinw: %s',ME.message);
end

%% Symmetrising, and some other bits and bobs

%You can fold about some axis, to improve stats:
wsym=symmetrise_sqw(cc2a,[1,0,0],[0,0,1],[0,0,0]);%specify a plane using 2 vectors in it, and an
%offset of this plane from the origin. So the above should fold about the
%line h=0:

plot(wsym)

%You can perform binary operations using objects and scalars:
wadd=cc2a+27;
plot(wadd);%notice the changed limits of the colour scale!

% if all above is successful, remove generated nxspe files sample
% sqw file to clean-up and do not leave results of the this script
% operations.
for i=1:numel(spe_file)
    if isfile(spe_file{i})
        delete(spe_file{i});
    end
end
if isfile(sqw_file)
    delete(sqw_file);
end

%There is much much more in the Horace online manual:

%http://horace.isis.rl.ac.uk

%Please use that as your first port of call for reference material.

%Also, to get inline info about a particular function, type in Matlab
%>> help <function_name>
