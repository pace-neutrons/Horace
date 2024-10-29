% This script is based on horace_dempo_script. It illustrates comparison
% between Horace and spinW parameters. 
%
% After some efforts to achieve equivalence and explaining differecne, it
% should be converted into integration script.
%
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
% after generation, sqw file becomes the source of further analysis
data_source =sqw_file;


%====================================
%% Generate Horace data files
%====================================
%Run the command below to obtain the data we will use for the demo. This
%process can take a few minutes - be patient! Provide sqw file name as
%additional parameter, to ensure that if sqw is already there, you do not
%need to generated source files again.
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

%====================================
%% Make plots etc
%====================================

%Viewing axes to look at the data. These can be any orthogonal set you like
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

cc2a=cut_sqw(sqw_file,proj,[-3,0.05,3],[-3,0.05,3],[-0.1,0.1],[80,100]);
plot(cc2a)


% Simulation parameters are 300 0 2 10 2 and we try to recover it
%Do a fit. We'll fit parameters 1, 3 and 5 in our model, but leave 2 and 4
%fixed (2nd vector is list of free parameters). We will
%also have a backgound function (specified separately). The (optional) list
%argument gives a verbose output during the fitting process
J = 300;     % Exchange interaction in meV
D = 0;       % Single-ion anisotropy in meV
gam  = 2;   % Intrinsic linewidth in meV (inversely proportional to excitation lifetime)
temp = 10;  % Sample measurement temperature in Kelvin
amp  = 2;  % Magnitude of the intensity of the excitation (arbitrary units)

% Simulate a model for S(Q,w):
% (This is an example where the user can provide the spectral weight as a
% function of (vector) Q and energy)
w_sqw=sqw_eval(cc2a,@demo_FM_spinwaves,[J D gam temp amp]);
w_sqw.pix.variance  = 1;
w_sqw.data.e = 1;


kk = multifit_sqw (w_sqw);
kk = kk.set_fun (@demo_FM_spinwaves);

kk = kk.set_pin ([J D gam temp amp]); %input parameters
kk = kk.set_free ([1 0 1 0 1]); %fitting parameters 1, 3 and 5

kk = kk.set_bfun (@constant_background); % set_bfun sets the background functions
kk = kk.set_bpin (0.05);   % initial background constant
kk = kk.set_bfree (1);    % fix the background
kk = kk.set_options('fit_control_parameters',[0.001 30 0.001],'listing',2);
sh = kk.simulate();
plot(sh)
keep_figure;
[wfit_hor fitdata_hor]=kk.fit();
plot(wfit_hor)
keep_figure

%Use spinW to calculate the S(Q,w) instead. First setup the spinW model.

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

kk = multifit_sqw (w_sqw);
kk = kk.set_fun (@fefm.horace_sqw, {[50 D gam temp amp], cpars{:}});

kk = kk.set_free ([1 0 1 0 1]); %fitting parameters 1,3 and 5

kk = kk.set_bfun (@constant_background); % set_bfun sets the background functions
kk = kk.set_bpin (0.05);   % initial background constant
kk = kk.set_bfree (1);    % fix the background
kk = kk.set_options('fit_control_parameters',[0.001 30 0.001],'listing',2);
ssw = kk.simulate();
plot(ssw);
keep_figure;
[wfit_sw fitdata_sw]=kk.fit();
plot(wfit_sw);

